"""Fixtures for the confcrypt CLI tests (seam 2).

Every value in here is obviously fake. Keys are generated per run and
live only in pytest's tmp dirs.
"""
import shutil
import subprocess
import sys
from pathlib import Path

import pyrage
import pytest

HERE = Path(__file__).resolve().parent
CONFCRYPT = HERE.parent / "confcrypt.py"
REAL_CONFIG = HERE.parents[2] / "Router Configs" / ".confcrypt.yml"


class Key:
    def __init__(self, directory: Path, name: str):
        ident = pyrage.x25519.Identity.generate()
        self.public = str(ident.to_public())
        self.path = directory / f"{name}.txt"
        self.path.write_text(f"# public key: {self.public}\n{ident}\n")


class Workspace:
    """A temp repo: .sops.yaml, .confcrypt.yml and throwaway keys."""

    def __init__(self, root: Path):
        self.root = root
        self.dir = root / "cfg"
        self.dir.mkdir()
        self.daily = Key(root, "daily")
        self.backup = Key(root, "backup")
        self.write_sops([self.daily, self.backup])
        shutil.copy(REAL_CONFIG, self.dir / ".confcrypt.yml")

    def write_sops(self, keys):
        recipients = ",".join(k.public for k in keys)
        (self.root / ".sops.yaml").write_text(
            "creation_rules:\n"
            "  - path_regex: '.*\\.sops\\.ya?ml$'\n"
            "    encrypted_regex: '.*'\n"
            f"    age: '{recipients}'\n"
        )

    def write(self, name: str, data: bytes) -> Path:
        p = self.dir / name
        p.write_bytes(data)
        return p

    def run(self, *args, key=None, check=False, env=None):
        key = key or self.daily
        base = {"SOPS_AGE_KEY_FILE": str(key.path), "PATH": "", "SYSTEMROOT": "C:\\Windows"}
        env = {**base, **(env or {})}
        proc = subprocess.run(
            [sys.executable, str(CONFCRYPT), *map(str, args)],
            capture_output=True, env=env, cwd=self.root,
        )
        if check and proc.returncode != 0:
            raise AssertionError(f"confcrypt {args[0]} failed: {proc.stderr.decode(errors='replace')}")
        return proc

    def encrypt(self, path: Path, **kw) -> bytes:
        (self.dir / "tmp").mkdir(exist_ok=True)
        out = self.dir / "tmp" / ("enc_" + path.name)
        self.run("encrypt", path, "-o", out, check=True, **kw)
        return out.read_bytes()

    def decrypt_bytes(self, enc: bytes, name: str, **kw) -> bytes:
        (self.dir / "tmp").mkdir(exist_ok=True)
        src = self.dir / "tmp" / name
        src.write_bytes(enc)
        out = self.dir / "tmp" / ("out_" + name)
        self.run("decrypt", src, "-o", out, check=True, **kw)
        return out.read_bytes()


@pytest.fixture
def ws(tmp_path):
    return Workspace(tmp_path)
