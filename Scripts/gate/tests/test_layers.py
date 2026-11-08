"""Seam 1 (continued): confcrypt layer, SOPS layer, Ignored set, fail-closed, modes."""
import base64

import pyrage
import pytest
import yaml

from conftest import ROUTER_DIR, rnd

RSC = (
    "# fixture router config\n"
    "/user add name=admin group=full password={pw}\n"
    '/interface/wifi/security add name=home pre-shared-key="{psk} with spaces"\n'
    "/snmp community add name={comm}\n"
    "/interface bridge add name=br0 comment=aa:bb:cc:dd:ee:ff\n"
)
IOS = (
    "! fixture\n"
    "enable secret 9 $9${h1}\n"
    "username wonka privilege 15 secret 9 $9${h2}\n"
    "line vty 0 4\n"
    " password 7 {h3}\n"
)
HV = "Disaster_Recovery/Templates/host_vars"


def _encrypted_tree(repo):
    repo.write(f"{ROUTER_DIR}/Router1.rsc", RSC.format(pw=rnd(12), psk=rnd(16), comm=rnd(10)))
    repo.write(f"{ROUTER_DIR}/Router3.ios", IOS.format(h1=rnd(30), h2=rnd(30), h3=rnd(14).upper()))
    repo.write(f"{ROUTER_DIR}/WiFi's.txt", f"home ssid\npsk {rnd(16)}\nlicense {rnd(20)}\n")
    for f in ("Router1.rsc", "Router3.ios", "WiFi's.txt"):
        repo.confcrypt_encrypt(f"{ROUTER_DIR}/{f}")
    repo.write(f"{HV}/vault1.yml", f"token: {rnd(20)}\nnested:\n  key: {rnd(12)}\n")
    repo.write("app/db.sops.yml", f"db_password: {rnd(14)}\n")
    repo.sops_encrypt(f"{HV}/vault1.yml")
    repo.sops_encrypt("app/db.sops.yml")


def test_correctly_encrypted_router_wifi_and_sops_files_pass(repo):
    _encrypted_tree(repo)
    repo.stage_all()
    r = repo.gate("--staged")
    assert r.code == 0, r.text
    repo.commit()
    r = repo.gate("--all")
    assert r.code == 0, r.text


def test_plaintext_line_in_confcrypt_managed_file_fails(repo):
    _encrypted_tree(repo)
    comm = rnd(10)
    p = repo.root / ROUTER_DIR / "Router1.rsc"
    p.write_bytes(p.read_bytes() + f"/snmp community add name={comm}\n".encode())
    repo.stage_all()
    r = repo.gate("--staged")
    assert r.code != 0
    assert "confcrypt" in r.text and "Router1.rsc" in r.text
    assert comm not in r.text


def test_sops_governed_file_without_metadata_fails(repo):
    val = rnd(14)
    repo.write(f"{HV}/auth1.yml", f"admin_pw: x{val}\n")
    repo.write("app/new.sops.yaml", f"name: harmless-{val}\n")
    repo.stage_all()
    r = repo.gate("--staged")
    assert r.code != 0
    assert "sops" in r.text.lower()
    assert "auth1.yml" in r.text and "new.sops.yaml" in r.text
    assert val not in r.text


def test_sops_file_with_forged_metadata_and_plaintext_value_fails(repo):
    repo.write("app/x.sops.yml", "a: plain\nsops:\n  mac: ENC[fake]\n")
    repo.stage_all()
    r = repo.gate("--staged")
    assert r.code != 0 and "x.sops.yml" in r.text


def test_tracked_ignored_set_path_fails_in_all_mode_only(repo):
    repo.write(f"{ROUTER_DIR}/Backups/old.txt", "harmless\n")
    repo.git("add", "-f", "--", f"{ROUTER_DIR}/Backups/old.txt")
    assert repo.gate("--staged").code == 0
    repo.git("commit", "-q", "-m", "forced")
    r = repo.gate("--all")
    assert r.code != 0
    assert "Backups/old.txt" in r.text


@pytest.mark.parametrize("var,tool", [("GATE_GITLEAKS", "gitleaks"), ("GATE_SOPS", "sops"), ("GATE_PYTHON", "python")])
@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_missing_tool_fails_closed_with_clear_message(repo, var, tool, mode):
    r = repo.gate(mode, **{var: "no-such-tool-xyz"})
    assert r.code != 0
    assert tool in r.text and "not found" in r.text


def test_staged_mode_scans_the_index_not_the_working_tree(repo):
    path = "docs/example.txt"
    repo.write(path, "clean\n")
    repo.commit()
    repo.write(path, f"/user add name=a group=full password={rnd(14)}\n")  # unstaged
    assert repo.gate("--staged").code == 0


def test_all_mode_catches_a_secret_removed_in_a_later_commit(repo):
    path = "docs/example.txt"
    repo.write(path, f'db_password: "{rnd(16)}"\n')
    repo.commit("oops")
    repo.write(path, "clean\n")
    repo.commit("fix")
    r = repo.gate("--all")
    assert r.code != 0 and "history" in r.text


@pytest.mark.parametrize("stage", [True, False], ids=["staged", "unstaged"])
def test_all_mode_scans_the_current_tree_not_only_history(repo, stage):
    path = "group_vars/db.yml"
    repo.write(path, "db_password: <SET_ME>\n")
    repo.commit()
    value = rnd(16)
    repo.write(path, f'db_password: "{value}"\n')  # never committed
    if stage:
        repo.stage_all()
    r = repo.gate("--all")
    assert r.code != 0, r.text
    assert path in r.text
    assert value not in r.text


# ---- encrypted-line allowlist: exact confcrypt lines only -------------------

@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_redacted_token_does_not_hide_a_plaintext_credential(repo, mode):
    value = rnd(18)
    repo.write("group_vars/db.yml", f"db_password: {value} # REDACTED\n")
    if mode == "--all":
        repo.commit()
    else:
        repo.stage_all()
    r = repo.gate(mode)
    assert r.code != 0, r.text
    assert "group_vars/db.yml" in r.text
    assert value not in r.text


def test_redacted_token_does_not_hide_an_identifying_detail_from_review(repo):
    who = "u" + rnd(8).lower()
    repo.write("docs/contact.md", f"mail {who}@example.org # REDACTED\n")
    repo.stage_all()
    r = repo.gate("--staged")
    assert r.code == 0, r.text
    assert "docs/contact.md:1" in r.text


def _every_dummy_encrypted(repo):
    """One confcrypt-managed file per dialect holding every rule dummy as an
    Encrypted line (metadata line, then the exact dummy)."""
    cfg = yaml.safe_load((repo.root / ROUTER_DIR / ".confcrypt.yml").read_text())
    ident = pyrage.x25519.Identity.from_str(repo.key_file.read_text().strip())
    names = {"rsc": "Router1.rsc", "ios": "Router3.ios", "wifi": "WiFi's.txt"}
    for dialect, ft in cfg["filetypes"].items():
        out = []
        for rule in ft["rules"]:
            blob = pyrage.encrypt(rnd(20).encode(), [ident.to_public()])
            out.append(f"{ft['comment']} confcrypt v2 {base64.urlsafe_b64encode(blob).rstrip(b'=').decode()}")
            out.append(rule["dummy"])
        repo.write(f"{ROUTER_DIR}/{names[dialect]}", "\n".join(out) + "\n")


@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_every_rule_dummy_as_encrypted_line_passes(repo, mode):
    _every_dummy_encrypted(repo)
    if mode == "--all":
        repo.commit()
    else:
        repo.stage_all()
    r = repo.gate(mode)
    assert r.code == 0, r.text
    assert "review" not in r.text
