"""Fixtures for the gate tests (seam 1: the gate entry point).

Everything secret-shaped is generated at run time from random parts, so no
source line contains a live-looking value. Age keys are throwaway per run.
"""
import os
import secrets
import shutil
import string
import subprocess
import sys
from pathlib import Path

import pyrage
import pytest

HERE = Path(__file__).resolve().parent
GATE_DIR = HERE.parent
REPO_ROOT = GATE_DIR.parents[1]
GATE = GATE_DIR / "gate.sh"
CONFCRYPT = REPO_ROOT / "Scripts" / "confcrypt" / "confcrypt.py"
ROUTER_DIR = "Router Configs"

ALNUM = string.ascii_letters + string.digits


def rnd(n, alphabet=ALNUM):
    return "".join(secrets.choice(alphabet) for _ in range(n))


def sh_exe():
    return shutil.which("sh") or "sh"


class Result:
    def __init__(self, proc):
        self.code = proc.returncode
        self.text = proc.stdout.decode(errors="replace") + proc.stderr.decode(errors="replace")


class Repo:
    """A small temp git repo with the real ignore rules and confcrypt config."""

    def __init__(self, root: Path):
        self.root = root
        root.mkdir(parents=True, exist_ok=True)
        self.git("init", "-q")
        self.git("config", "user.email", "t@example.invalid")
        self.git("config", "user.name", "t")
        self.git("config", "commit.gpgsign", "false")
        self.git("config", "core.autocrlf", "false")
        ident = pyrage.x25519.Identity.generate()
        self.key_file = root.parent / (root.name + "-key.txt")
        self.key_file.write_text(f"{ident}\n")
        self.write(
            ".sops.yaml",
            "creation_rules:\n"
            "  - path_regex: 'Disaster_Recovery[/\\\\]Templates[/\\\\]host_vars[/\\\\](vault1|auth1|seeder1)\\.yml$'\n"
            "    encrypted_regex: '.*'\n"
            f"    age: '{ident.to_public()}'\n"
            "  - path_regex: '(^|[/\\\\])[^/\\\\]*\\.sops\\.(ya?ml|json|env)$'\n"
            "    encrypted_regex: '.*'\n"
            f"    age: '{ident.to_public()}'\n",
        )
        shutil.copy(REPO_ROOT / ".gitignore", root / ".gitignore")
        self.write(f"{ROUTER_DIR}/.confcrypt.yml", (REPO_ROOT / ROUTER_DIR / ".confcrypt.yml").read_text())
        self.commit("base")

    def git(self, *args):
        p = subprocess.run(["git", *args], cwd=self.root, capture_output=True)
        assert p.returncode == 0, p.stderr.decode(errors="replace")
        return p.stdout.decode()

    def write(self, rel, text):
        p = self.root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(text.encode())
        return p

    def stage_all(self):
        self.git("add", "-A")

    def commit(self, msg="c"):
        self.stage_all()
        self.git("commit", "-q", "-m", msg)

    def confcrypt_encrypt(self, rel):
        p = subprocess.run(
            [sys.executable, str(CONFCRYPT), "encrypt", rel, "--in-place"],
            cwd=self.root, capture_output=True,
        )
        assert p.returncode == 0, p.stderr.decode(errors="replace")

    def sops_encrypt(self, rel):
        env = dict(os.environ, SOPS_AGE_KEY_FILE=str(self.key_file))
        p = subprocess.run(["sops", "encrypt", "--in-place", rel], cwd=self.root, capture_output=True, env=env)
        assert p.returncode == 0, p.stderr.decode(errors="replace")

    def gate(self, mode, **env):
        e = dict(os.environ)
        e.update(env)
        return Result(subprocess.run([sh_exe(), str(GATE), mode], cwd=self.root, capture_output=True, env=e))


@pytest.fixture
def repo(tmp_path):
    return Repo(tmp_path / "repo")
