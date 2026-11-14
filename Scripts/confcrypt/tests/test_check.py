"""confcrypt check: key-less verification, tested through the CLI."""
import subprocess
import sys

from conftest import CONFCRYPT

FAKE_RSC = (
    b"# fake router fixture\n"
    b'/user add name=fakeadmin group=full password="fake pass word tail"\n'
    b"/system identity set name=fixture\n"
)
DUMMY = b"/user add name=REDACTED group=REDACTED password=REDACTED\n"


def check(ws, *paths):
    return ws.run("check", *paths)


def test_encrypted_file_passes_and_plaintext_rule_line_fails(ws):
    enc = ws.write("enc.rsc", ws.encrypt(ws.write("r1.rsc", FAKE_RSC)))
    assert check(ws, enc).returncode == 0
    plain = ws.write("plain.rsc", FAKE_RSC)
    proc = check(ws, plain)
    assert proc.returncode == 1
    assert b"fake pass word" not in proc.stdout + proc.stderr
    assert b"plain.rsc:2" in proc.stderr


def test_bare_dummy_without_metadata_line_fails(ws):
    f = ws.write("bare.rsc", b"/system identity set name=x\n" + DUMMY)
    assert check(ws, f).returncode == 1


def test_malformed_metadata_line_fails(ws):
    f = ws.write("bad.rsc", b"# confcrypt v2 !!!notbase64!!!\n" + DUMMY)
    assert check(ws, f).returncode == 1
    f = ws.write("bad2.rsc", b"# confcrypt v2 aGVsbG8\n" + DUMMY)  # not an age blob
    assert check(ws, f).returncode == 1
    f = ws.write("bad3.rsc", b"# confcrypt v3 whatever\n" + DUMMY)
    assert check(ws, f).returncode == 1


def test_metadata_line_without_dummy_below_fails(ws):
    good = ws.encrypt(ws.write("r1.rsc", FAKE_RSC)).split(b"\n")
    meta = next(l for l in good if l.startswith(b"# confcrypt v2 "))
    at_eof = ws.write("eof.rsc", meta + b"\n")
    assert check(ws, at_eof).returncode == 1
    not_dummy = ws.write("nd.rsc", meta + b"\n/system identity set name=x\n")
    assert check(ws, not_dummy).returncode == 1


def test_tripwire_hit_not_covered_by_a_rule_fails(ws):
    f = ws.write("trip.rsc", b"/some thing set secret=fake\n")
    assert check(ws, f).returncode == 1
    clean = ws.write("clean.rsc", b"/system identity set name=x\n")
    assert check(ws, clean).returncode == 0


def test_ios_password_encryption_service_is_not_a_tripwire_hit(ws):
    # `service password-encryption` turns on type-7 hashing; it holds no secret,
    # and IOS lines cannot carry a confcrypt:ignore marker.
    f = ws.write("svc.ios", b"service password-encryption\nno service password-encryption\n")
    proc = check(ws, f)
    assert proc.returncode == 0, proc.stderr
    # an uncovered password line in the same dialect still trips
    trip = ws.write("trip.ios", b"ip ftp password fakepw\n")
    assert check(ws, trip).returncode == 1


def test_ignore_marker_allowlists_a_reviewed_line(ws):
    f = ws.write(
        "ign.rsc",
        b"/some thing set secret=fake # confcrypt:ignore\n"
        b'/user add name=a password="x" # confcrypt:ignore\n',
    )
    assert check(ws, f).returncode == 0


def test_check_runs_with_no_key_and_reports_every_file(ws):
    ws.write("ok.rsc", b"/system identity set name=x\n")
    ws.write("bad.rsc", FAKE_RSC)
    (ws.root / ".sops.yaml").unlink()
    proc = subprocess.run(
        [sys.executable, str(CONFCRYPT), "check", "cfg/ok.rsc", "cfg/bad.rsc"],
        capture_output=True, cwd=ws.root, env={"PATH": "", "SYSTEMROOT": "C:\\Windows"},
    )
    assert proc.returncode == 1
    assert b"bad.rsc:2" in proc.stderr
