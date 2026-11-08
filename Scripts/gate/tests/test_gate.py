"""Seam 1: run the real gate against temp git repos and assert outcomes."""
import os
import shutil
import subprocess

import pytest

from conftest import CONFCRYPT, GATE_DIR, REPO_ROOT, ROUTER_DIR, rnd, sh_exe


def test_clean_tree_passes_in_both_modes(repo):
    repo.write("README.md", "hello\n")
    repo.stage_all()
    r = repo.gate("--staged")
    assert r.code == 0, r.text
    repo.commit()
    r = repo.gate("--all")
    assert r.code == 0, r.text


# ---- layer a: gitleaks (defaults plus custom rules) ----------------------

def _shapes():
    """(id, file, line-builder). Fakes are built at run time; none is committed."""
    return [
        ("cipassword", "Terraform/main.tf", lambda v: f'  cipassword = "{v}"\n'),
        ("routeros-password", "docs/example.txt", lambda v: f"/user add name=admin group=full password={v}\n"),
        ("routeros-psk", "docs/example.txt", lambda v: f"/interface/wifi/security add pre-shared-key={v}\n"),
        ("cisco-secret-9", "docs/example.txt", lambda v: f"username wonka privilege 15 secret 9 $9${v}\n"),
        ("cisco-password-7", "docs/example.txt", lambda v: f"line vty 0 4\n password 7 {v}\n"),
        ("discord-webhook", "docs/notes.txt",
         lambda v: "https://discord.com/api/webhooks/" + "1" * 18 + "/" + v + v + "\n"),
        ("pushover-key", "docs/notes.txt", lambda v: "pushover_token = " + v.lower()[:30].ljust(30, "a") + "\n"),
        ("plain-password", "group_vars/db.yml", lambda v: f'db_password: "{v}"\n'),
        ("default-gitlab-pat", "docs/notes.txt", lambda v: "glpat-" + v[:20].ljust(20, "x") + "\n"),
    ]


@pytest.mark.parametrize("mode", ["--staged", "--all"])
@pytest.mark.parametrize("name,path,build", _shapes(), ids=[s[0] for s in _shapes()])
def test_audited_plaintext_credential_fails_and_is_never_printed(repo, mode, name, path, build):
    value = rnd(24)
    repo.write(path, build(value))
    if mode == "--all":
        repo.commit()
    else:
        repo.stage_all()
    r = repo.gate(mode)
    assert r.code != 0, f"{name} passed the gate"
    assert path in r.text
    assert value not in r.text
    assert value.lower() not in r.text.lower()


# ---- identifying details: reported for review, never blocking -------------

def _mk(repo, mode, path, text):
    repo.write(path, text)
    if mode == "--all":
        repo.commit()
    else:
        repo.stage_all()


@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_stray_email_is_reported_but_does_not_fail(repo, mode):
    who = "u" + rnd(8).lower()
    _mk(repo, mode, "docs/contact.md", f"mail {who}@example.org for access\n")
    r = repo.gate(mode)
    assert r.code == 0, r.text
    assert "review" in r.text and "docs/contact.md:1" in r.text
    assert who not in r.text


@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_public_ip_is_reported_but_resolvers_and_private_ranges_are_not(repo, mode):
    _mk(repo, mode, "docs/net.md",
        "dns 1.1.1.1 and 9.9.9.9\n"
        "lan 10.1.2.3 172.16.5.5 192.168.1.1 127.0.0.1 0.0.0.0 255.255.255.0\n"
        "stray 203.0.113.9 is documentation\n"
        "stray 8.8.4.4 here\n")
    r = repo.gate(mode)
    assert r.code == 0, r.text
    assert "docs/net.md:4" in r.text
    for line in (1, 2, 3):
        assert f"docs/net.md:{line}" not in r.text
    assert "8.8.4.4" not in r.text


@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_lab_domain_is_not_flagged(repo, mode):
    _mk(repo, mode, "docs/hosts.md", "vault1.mikewashere.lan\nadmin@mikewashere.lan\n")
    r = repo.gate(mode)
    assert r.code == 0, r.text
    assert "docs/hosts.md" not in r.text


def test_lab_domain_and_resolvers_come_from_the_review_config(repo, tmp_path):
    """The blueprint's own values live in Scripts/gate/review.yml, not in code."""
    gate_copy = tmp_path / "gatecopy"
    shutil.copytree(GATE_DIR, gate_copy / "Scripts" / "gate", ignore=shutil.ignore_patterns("tests", "__pycache__"))
    shutil.copytree(CONFCRYPT.parent, gate_copy / "Scripts" / "confcrypt", ignore=shutil.ignore_patterns("tests", "__pycache__"))
    shutil.copy(REPO_ROOT / ".gitleaks.toml", gate_copy / ".gitleaks.toml")
    (gate_copy / "Scripts" / "gate" / "review.yml").write_text(
        "lab_domain: other.example\nresolvers:\n  - 8.8.4.4\n")
    repo.write("docs/hosts.md", "admin@other.example\ndns 8.8.4.4\nadmin@mikewashere.lan\ndns 1.1.1.1\n")
    repo.stage_all()
    p = subprocess.run([sh_exe(), str(gate_copy / "Scripts" / "gate" / "gate.sh"), "--staged"],
                       cwd=repo.root, capture_output=True, env=dict(os.environ))
    text = p.stdout.decode(errors="replace") + p.stderr.decode(errors="replace")
    assert p.returncode == 0, text
    assert "docs/hosts.md:1" not in text and "docs/hosts.md:2" not in text
    assert "docs/hosts.md:3: email" in text
    assert "docs/hosts.md:4: public-ip" in text


@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_mac_outside_router_configs_is_reported_but_does_not_fail(repo, mode):
    _mk(repo, mode, "docs/inventory.md", "nic aa:bb:cc:00:11:22\n")
    r = repo.gate(mode)
    assert r.code == 0, r.text
    assert "review" in r.text and "docs/inventory.md:1" in r.text
    assert "aa:bb:cc:00:11:22" not in r.text.lower()


@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_plaintext_mac_in_router_config_fails(repo, mode):
    _mk(repo, mode, f"{ROUTER_DIR}/R9.rsc", "/interface ethernet set ether1 mac-address=AA:BB:CC:00:11:22\n")
    r = repo.gate(mode)
    assert r.code != 0
    assert "R9.rsc:1" in r.text
    assert "aa:bb:cc:00:11:22" not in r.text.lower()


def test_encrypted_router_config_mac_is_not_reported(repo):
    repo.write(f"{ROUTER_DIR}/R9.rsc", "/interface ethernet set ether1 mac-address=AA:BB:CC:00:11:22\n")
    repo.confcrypt_encrypt(f"{ROUTER_DIR}/R9.rsc")
    repo.commit()
    r = repo.gate("--all")
    assert r.code == 0, r.text
    assert "review" not in r.text


# ---- reviewed false positives --------------------------------------------

@pytest.mark.parametrize("mode", ["--staged", "--all"])
def test_inline_allow_passes_and_other_lines_still_fail(repo, mode):
    v = rnd(24)
    _mk(repo, mode, "docs/example.txt", f"/user add name=a group=full password={v} # gitleaks:allow\n")
    r = repo.gate(mode)
    assert r.code == 0, r.text
    repo.write("docs/other.txt", f"/user add name=a group=full password={rnd(24)}\n")
    repo.stage_all()
    assert repo.gate("--staged").code != 0


def test_commented_path_allowlist_entry_passes(repo, tmp_path):
    gate_copy = tmp_path / "gatecopy"
    shutil.copytree(GATE_DIR, gate_copy / "Scripts" / "gate", ignore=shutil.ignore_patterns("tests", "__pycache__"))
    shutil.copytree(CONFCRYPT.parent, gate_copy / "Scripts" / "confcrypt", ignore=shutil.ignore_patterns("tests", "__pycache__"))
    cfg = (REPO_ROOT / ".gitleaks.toml").read_text()
    cfg += (
        "\n# reviewed: fixture docs quote fake credential shapes\n"
        "[[allowlists]]\n"
        'description = "test fixture docs"\n'
        "paths = ['''^docs/example[.]txt$''']\n"
    )
    (gate_copy / ".gitleaks.toml").write_text(cfg)
    repo.write("docs/example.txt", f"/user add name=a group=full password={rnd(24)}\n")
    repo.commit()
    assert repo.gate("--all").code != 0  # the real config has no such entry
    e = dict(os.environ)
    p = subprocess.run([sh_exe(), str(gate_copy / "Scripts" / "gate" / "gate.sh"), "--all"],
                       cwd=repo.root, capture_output=True, env=e)
    assert p.returncode == 0, p.stderr.decode(errors="replace")


def test_gitleaksignore_file_is_not_honoured(repo):
    repo.write("docs/example.txt", f"/user add name=a group=full password={rnd(24)}\n")
    repo.commit()
    commit = repo.git("rev-parse", "HEAD").strip()
    repo.write(".gitleaksignore",
               f"docs/example.txt:routeros-password:1\n{commit}:docs/example.txt:routeros-password:1\n"
               f"{commit}:docs/example.txt:password-not-placeholder:1\ndocs/example.txt:password-not-placeholder:1\n")
    repo.commit()
    assert repo.gate("--all").code != 0
