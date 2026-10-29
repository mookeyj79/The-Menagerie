"""confcrypt edit: temp-file hygiene, failure handling, byte fidelity."""
import os

from test_confcrypt_edit import FAKE_RSC, blobs, make_editor

RECORD = (
    "import os, stat\n"
    "open(os.environ['REC'], 'w').write(path + '\\n' + oct(stat.S_IMODE(os.stat(path).st_mode)))\n"
)


def test_temp_file_is_owner_only_and_removed_after_success(ws):
    enc = ws.encrypt(ws.write("r1.rsc", FAKE_RSC))
    target = ws.write("edit.rsc", enc)
    rec = ws.root / "rec.txt"
    env = make_editor(ws, RECORD)
    env["REC"] = str(rec)
    ws.run("edit", target, env=env, check=True)
    tmp_path, mode = rec.read_text().split("\n")
    assert not os.path.exists(tmp_path)
    if os.name != "nt":  # POSIX mode bits are meaningless on Windows
        assert int(mode, 8) & 0o077 == 0
    assert target.read_bytes() == enc  # no-op edit leaves the file as is


def test_temp_file_is_removed_and_target_unchanged_when_editor_fails(ws):
    enc = ws.encrypt(ws.write("r1.rsc", FAKE_RSC))
    target = ws.write("edit.rsc", enc)
    rec = ws.root / "rec.txt"
    env = make_editor(
        ws,
        RECORD + "open(path, 'ab').write(b'/user add name=x password=fake\\n')\n"
        "sys.exit(3)\n",
    )
    env["REC"] = str(rec)
    proc = ws.run("edit", target, env=env)
    assert proc.returncode != 0
    tmp_path, _ = rec.read_text().split("\n")
    assert not os.path.exists(tmp_path)
    assert target.read_bytes() == enc
    assert b"fake pass" not in proc.stderr + proc.stdout


def test_edit_preserves_crlf_and_utf8(ws):
    data = (
        '/user add name=fakeadmin password="fake über"\r\n'
        "# café\r\n"
        "/system identity set name=x"
    ).encode("utf-8")
    enc = ws.encrypt(ws.write("c.rsc", data))
    target = ws.write("c_edit.rsc", enc)
    env = make_editor(
        ws,
        "t = open(path, 'rb').read()\n"
        "open(path, 'wb').write(t.replace(b'name=x', b'name=y'))\n",
    )
    ws.run("edit", target, env=env, check=True)
    out = target.read_bytes()
    assert ws.decrypt_bytes(out, "c_edit.rsc") == data.replace(b"name=x", b"name=y")
    assert blobs(out) == blobs(enc)
