"""confcrypt edit: decrypt, run $EDITOR, re-encrypt reusing unchanged blobs."""
import sys
from pathlib import Path

FAKE_RSC = (
    b"# fake router fixture\n"
    b'/user add name=fakeadmin group=full password="fake pass one"\n'
    b'/user add name=fakeguest group=read password="fake pass two"\n'
    b"/system identity set name=fixture\n"
)


def make_editor(ws, body: str) -> dict:
    """A fake $EDITOR: runs `body` (python) with `path` bound to the temp file."""
    script = ws.root / "fake_editor.py"
    script.write_text("import sys\npath = sys.argv[1]\n" + body)
    cmd = f'"{Path(sys.executable).as_posix()}" "{script.as_posix()}"'
    return {"EDITOR": cmd}


def blobs(data: bytes):
    return [ln for ln in data.split(b"\n") if ln.startswith(b"# confcrypt v2 ")]


def test_editing_one_line_changes_exactly_one_blob(ws):
    enc = ws.encrypt(ws.write("r1.rsc", FAKE_RSC))
    target = ws.write("edit.rsc", enc)
    env = make_editor(
        ws,
        "t = open(path, 'rb').read()\n"
        "open(path, 'wb').write(t.replace(b'fake pass two', b'fake pass 2b'))\n",
    )
    ws.run("edit", target, env=env, check=True)
    after = target.read_bytes()
    before_b, after_b = blobs(enc), blobs(after)
    assert len(before_b) == len(after_b) == 2
    assert sum(a != b for a, b in zip(before_b, after_b)) == 1
    assert before_b[0] == after_b[0]
    expected = FAKE_RSC.replace(b"fake pass two", b"fake pass 2b")
    assert ws.decrypt_bytes(after, "edit.rsc") == expected
