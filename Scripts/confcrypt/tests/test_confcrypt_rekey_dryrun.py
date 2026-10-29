"""confcrypt rekey and encrypt --dry-run, tested through the CLI."""
from test_confcrypt_edit import FAKE_RSC, blobs

from conftest import Key


def test_rekey_changes_all_blobs_and_file_decrypts_with_new_recipient_set(ws):
    enc = ws.encrypt(ws.write("r1.rsc", FAKE_RSC))
    target = ws.write("rk.rsc", enc)
    new = Key(ws.root, "new")
    ws.write_sops([ws.daily, new])  # backup out, new in
    ws.run("rekey", target, "--in-place", check=True)
    after = target.read_bytes()
    before_b, after_b = blobs(enc), blobs(after)
    assert len(before_b) == len(after_b) == 2
    assert all(a != b for a, b in zip(before_b, after_b))
    # decrypts with the new key alone and with the daily key alone
    assert ws.decrypt_bytes(after, "rk.rsc", key=new) == FAKE_RSC
    assert ws.decrypt_bytes(after, "rk.rsc", key=ws.daily) == FAKE_RSC
    # the dropped backup key no longer works
    (ws.dir / "tmp").mkdir(exist_ok=True)
    src = ws.dir / "tmp" / "old.rsc"
    src.write_bytes(after)
    assert ws.run("decrypt", src, key=ws.backup).returncode != 0


def test_dry_run_reports_file_line_and_rule_but_never_a_value(ws):
    src = ws.write("dr.rsc", FAKE_RSC)
    out = ws.dir / "should_not_exist.rsc"
    proc = ws.run("encrypt", src, "--dry-run", "-o", out, check=True)
    report = proc.stdout + proc.stderr
    assert b"dr.rsc:2" in report and b"dr.rsc:3" in report
    assert b"dr.rsc:1" not in report and b"dr.rsc:4" not in report
    assert b"rule" in report
    for secret in (b"fake pass", b"fakeadmin", b"fakeguest"):
        assert secret not in report
    assert src.read_bytes() == FAKE_RSC  # nothing written
    assert not out.exists()


def test_dry_run_needs_no_key_and_skips_already_encrypted_lines(ws):
    enc = ws.encrypt(ws.write("r1.rsc", FAKE_RSC))
    src = ws.write("done.rsc", enc)
    proc = ws.run("encrypt", src, "--dry-run", check=True)
    assert b"done.rsc:" not in proc.stdout + proc.stderr
