"""Hook and install-script tests on temp repos. All secret values are fake and
generated at run time."""
import secrets
import shutil
import string
import subprocess
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parents[3]
ALNUM = string.ascii_letters + string.digits


def git(cwd, *args, check=True):
    p = subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True)
    if check:
        assert p.returncode == 0, p.stderr
    return p


@pytest.fixture
def clone(tmp_path):
    for tool in ("gitleaks", "sops"):
        if not shutil.which(tool):
            pytest.skip(f"{tool} not installed")
    root = tmp_path / "r"
    root.mkdir()
    git(root, "init", "-q")
    for k, v in (("user.email", "t@example.invalid"), ("user.name", "t"),
                 ("commit.gpgsign", "false"), ("core.autocrlf", "false")):
        git(root, "config", k, v)
    shutil.copytree(REPO / ".githooks", root / ".githooks")
    shutil.copytree(REPO / "Scripts" / "gate", root / "Scripts" / "gate",
                    ignore=shutil.ignore_patterns("__pycache__", "tests", ".pytest_cache"))
    shutil.copytree(REPO / "Scripts" / "confcrypt", root / "Scripts" / "confcrypt",
                    ignore=shutil.ignore_patterns("__pycache__", "tests", ".pytest_cache"))
    (root / "Router Configs").mkdir()
    shutil.copy(REPO / "Router Configs" / ".confcrypt.yml", root / "Router Configs" / ".confcrypt.yml")
    shutil.copy(REPO / "Scripts" / "install-hooks.sh", root / "Scripts" / "install-hooks.sh")
    shutil.copy(REPO / ".gitleaks.toml", root / ".gitleaks.toml")
    (root / ".gitignore").write_text("")
    return root


def install(root):
    p = subprocess.run(["sh", str(root / "Scripts" / "install-hooks.sh")], capture_output=True, text=True)
    assert p.returncode == 0, p.stderr


def test_install_sets_hookspath(clone):
    install(clone)
    assert git(clone, "config", "core.hooksPath").stdout.strip() == ".githooks"


def test_hook_is_lf_and_thin():
    data = (REPO / ".githooks" / "pre-commit").read_bytes()
    assert b"\r" not in data
    text = data.decode()
    assert text.count("gate.sh") == 1 and "--staged" in text and "--all" not in text


def test_hook_blocks_plaintext_secret_and_allows_clean(clone):
    install(clone)
    (clone / "ok.txt").write_text("hello\n")
    git(clone, "add", "ok.txt")
    assert git(clone, "commit", "-qm", "clean", check=False).returncode == 0

    fake = "ghp_" + "".join(secrets.choice(ALNUM) for _ in range(36))
    (clone / "leak.txt").write_text(f"token = {fake}\n")
    git(clone, "add", "leak.txt")
    p = git(clone, "commit", "-qm", "leak", check=False)
    assert p.returncode != 0
    assert fake not in p.stdout + p.stderr
    assert git(clone, "rev-list", "--count", "HEAD").stdout.strip() == "1"
