"""confcrypt v2 core: whole-line encrypt and decrypt, tested through the CLI."""

FAKE_RSC = (
    b"# fake router fixture\n"
    b"/ip address add address=192.0.2.1/24 interface=ether1\n"
    b'/user add name=fakeadmin group=full password="fake pass word tail"\n'
    b"/system identity set name=fixture\n"
)


def test_encrypt_then_decrypt_round_trips_and_hides_the_line(ws):
    src = ws.write("r1.rsc", FAKE_RSC)
    enc = ws.encrypt(src)
    assert b"fake pass word" not in enc
    assert b"fakeadmin" not in enc
    assert ws.decrypt_bytes(enc, "r1.rsc") == FAKE_RSC


def test_crlf_utf8_and_missing_final_newline_round_trip_byte_exact(ws):
    data = (
        "# café fixture ☃\r\n"
        '/user add name=fakeadmin password="fake über pw"\r\n'
        "/system identity set name=last"
    ).encode("utf-8")
    enc = ws.encrypt(ws.write("crlf.rsc", data))
    assert "über".encode("utf-8") not in enc
    assert b"\r\n" in enc and b"\n" not in enc.replace(b"\r\n", b"")
    assert ws.decrypt_bytes(enc, "crlf.rsc") == data


def test_secret_on_final_line_without_newline_round_trips(ws):
    data = b'/user add name=fakeadmin password="fake tail"'
    enc = ws.encrypt(ws.write("last.rsc", data))
    assert ws.decrypt_bytes(enc, "last.rsc") == data


def test_encrypt_is_idempotent(ws):
    src = ws.write("r1.rsc", FAKE_RSC)
    enc = ws.encrypt(src)
    again = ws.write("again.rsc", enc)
    assert ws.encrypt(again) == enc


def test_dummy_that_matches_its_own_regex_is_not_treated_as_plaintext(ws):
    # The MAC dummy contains a MAC and matches the MAC rule's regex.
    src = ws.write("mac.rsc", b"/interface ethernet set mac-address=AA:BB:CC:00:11:22\n")
    enc = ws.encrypt(src)
    assert b"AA:BB:CC" not in enc
    again = ws.write("mac2.rsc", enc)
    assert ws.encrypt(again) == enc
    assert ws.decrypt_bytes(enc, "mac.rsc") == src.read_bytes()


def test_quoted_value_with_spaces_is_fully_hidden(ws):
    data = b'/user add name=x password="alpha beta gamma-tail" group=full\n'
    enc = ws.encrypt(ws.write("q.rsc", data))
    for frag in (b"alpha", b"beta", b"gamma-tail", b"group=full"):
        assert frag not in enc


def test_config_rejects_dummy_not_matching_its_own_regex(ws):
    (ws.dir / ".confcrypt.yml").write_text(
        "filetypes:\n  rsc:\n    comment: '#'\n    rules:\n"
        "      - regex: 'password='\n        dummy: 'nothing here'\n"
    )
    src = ws.write("bad.rsc", b"x\n")
    proc = ws.run("encrypt", src)
    assert proc.returncode != 0
    assert b"dummy does not match its own regex" in proc.stderr


def test_decrypt_errors_when_line_under_metadata_is_not_the_dummy(ws):
    enc = ws.encrypt(ws.write("r1.rsc", FAKE_RSC)).decode()
    lines = enc.split("\n")
    i = next(n for n, l in enumerate(lines) if l.startswith("# confcrypt v2 "))
    lines[i + 1] = "/user add name=tampered"
    bad = ws.dir / "tmp" / "tampered.rsc"
    bad.write_text("\n".join(lines), newline="")
    proc = ws.run("decrypt", bad, "-o", ws.dir / "tmp" / "o.rsc")
    assert proc.returncode != 0
    assert b"not the rule dummy" in proc.stderr


def test_metadata_line_at_end_of_file_is_an_error(ws):
    enc = ws.encrypt(ws.write("r1.rsc", FAKE_RSC)).decode()
    meta = next(l for l in enc.split("\n") if l.startswith("# confcrypt v2 "))
    bad = ws.dir / "tmp" / "eof.rsc"
    bad.write_text(meta + "\n", newline="")
    for cmd in ("decrypt", "encrypt"):
        proc = ws.run(cmd, bad, "-o", ws.dir / "tmp" / "o.rsc")
        assert proc.returncode != 0
        assert b"end of file" in proc.stderr


def test_each_recipient_key_alone_decrypts(ws):
    data = FAKE_RSC
    enc = ws.encrypt(ws.write("r1.rsc", data))
    assert ws.decrypt_bytes(enc, "r1.rsc", key=ws.daily) == data
    assert ws.decrypt_bytes(enc, "r1.rsc", key=ws.backup) == data


def test_output_never_contains_the_secret(ws):
    src = ws.write("r1.rsc", FAKE_RSC)
    out = ws.dir / "tmp" / "o.rsc"
    (ws.dir / "tmp").mkdir(exist_ok=True)
    for proc in (ws.run("encrypt", src, "-o", out), ws.run("encrypt", src)):
        assert b"fake pass word" not in proc.stderr
    assert b"fake pass word" not in ws.run("encrypt", src).stdout
