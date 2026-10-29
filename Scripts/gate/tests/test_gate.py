"""Seam 1: run the real gate against temp git repos and assert outcomes."""
import pytest

from conftest import ROUTER_DIR, rnd


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
