"""Masked rules: the dummy keeps the line's structure with only the MAC zeroed."""
import pyrage

from test_confcrypt_edit import blobs

BRIDGES = (
    b"/interface bridge\n"
    b"add name=arch1_bridge    auto-mac=no admin-mac=AA:BB:CC:DD:EE:FF\n"
    b"add name=arch2_bridge    auto-mac=no admin-mac=FF:EE:CC:DD:BB:AA\n"
)


def dummies(enc, comment=b"#"):
    lines = enc.split(b"\n")
    return [lines[i + 1] for i, l in enumerate(lines) if l.startswith(comment + b" confcrypt v2 ")]


def test_mac_line_keeps_its_structure_and_round_trips(ws):
    enc = ws.encrypt(ws.write("br.rsc", BRIDGES))
    assert dummies(enc) == [
        b"REDACTED add name=arch1_bridge    auto-mac=no admin-mac=00:00:00:00:00:00",
        b"REDACTED add name=arch2_bridge    auto-mac=no admin-mac=00:00:00:00:00:00",
    ]
    assert b"AA:BB" not in enc and b"FF:EE" not in enc
    assert ws.decrypt_bytes(enc, "br.rsc") == BRIDGES
    assert ws.encrypt(ws.write("again.rsc", enc)) == enc
    assert ws.run("check", ws.write("enc.rsc", enc)).returncode == 0


def test_ios_mac_forms_and_indentation_are_kept(ws):
    data = (
        b"interface Vlan1\n"
        b" mac address-table static aaaa.bbbb.cccc vlan 1 interface Gi0/1\n"
        b" ip dhcp client-identifier aa-bb-cc-00-11-22\n"
    )
    enc = ws.encrypt(ws.write("m.ios", data))
    assert dummies(enc, b"!") == [
        b" REDACTED mac address-table static 0000.0000.0000 vlan 1 interface Gi0/1",
        b" REDACTED ip dhcp client-identifier 00-00-00-00-00-00",
    ]
    assert ws.decrypt_bytes(enc, "m.ios") == data
    assert ws.run("check", ws.write("enc.ios", enc)).returncode == 0


def test_secret_rules_still_win_over_the_mac_mask(ws):
    data = b"/interface wireguard add private-key=FAKEWG mac=AA:BB:CC:00:11:22\n"
    enc = ws.encrypt(ws.write("s.rsc", data))
    assert dummies(enc) == [b"/interface/wireguard add private-key=REDACTED"]


def test_check_rejects_a_masked_dummy_that_still_holds_a_mac(ws):
    enc = ws.encrypt(ws.write("br.rsc", BRIDGES))
    leaky = enc.replace(b"admin-mac=00:00:00:00:00:00", b"admin-mac=00:00:00:00:00:00 x=AA:BB:CC:DD:EE:FF", 1)
    assert ws.run("check", ws.write("leaky.rsc", leaky)).returncode == 1
    unmasked = enc.replace(b"admin-mac=00:00:00:00:00:00", b"admin-mac=", 1)
    assert ws.run("check", ws.write("nomac.rsc", unmasked)).returncode == 1


def test_decrypt_refuses_a_hand_edited_masked_dummy(ws):
    enc = ws.encrypt(ws.write("br.rsc", BRIDGES))
    edited = enc.replace(b"REDACTED add name=arch1_bridge", b"REDACTED add name=renamed", 1)
    src = ws.dir / "tmp" / "ed.rsc"
    src.write_bytes(edited)
    proc = ws.run("decrypt", src, "-o", ws.dir / "tmp" / "o.rsc")
    assert proc.returncode != 0
    assert b"not the rule dummy" in proc.stderr
    # still structurally a dummy, so key-less check accepts it
    assert ws.run("check", src).returncode == 0


def test_legacy_fixed_dummy_is_accepted_and_rekey_migrates_it(ws):
    original = "add name=arch1_bridge auto-mac=no admin-mac=AA:BB:CC:DD:EE:FF"
    rcp = [pyrage.x25519.Recipient.from_str(ws.daily.public)]
    from base64 import urlsafe_b64encode
    blob = urlsafe_b64encode(pyrage.encrypt(original.encode(), rcp)).rstrip(b"=")
    legacy = b"# confcrypt v2 " + blob + b"\n# REDACTED 00:00:00:00:00:00\n"
    f = ws.write("legacy.rsc", legacy)
    assert ws.run("check", f).returncode == 0
    assert ws.decrypt_bytes(legacy, "legacy.rsc") == original.encode() + b"\n"
    ws.run("rekey", f, "--in-place", check=True)
    after = f.read_bytes()
    assert dummies(after) == [b"REDACTED add name=arch1_bridge auto-mac=no admin-mac=00:00:00:00:00:00"]
    assert len(blobs(after)) == 1


def test_config_rejects_a_replace_its_own_mask_does_not_reproduce(ws):
    (ws.dir / ".confcrypt.yml").write_text(
        "filetypes:\n  rsc:\n    comment: '#'\n    rules:\n"
        "      - regex: 'pw=\\S+'\n"
        "        masks: [{regex: 'pw=\\S+', replace: 'HIDDEN'}]\n"
        "        dummy: 'REDACTED {masked}'\n"
    )
    proc = ws.run("encrypt", ws.write("bad.rsc", b"set pw=FAKE\n"))
    assert proc.returncode != 0
    assert b"stable dummy" in proc.stderr and b"FAKE" not in proc.stderr


def test_config_requires_one_masked_placeholder(ws):
    (ws.dir / ".confcrypt.yml").write_text(
        "filetypes:\n  rsc:\n    comment: '#'\n    rules:\n"
        "      - regex: 'x'\n"
        "        masks: [{regex: 'x', replace: 'x'}]\n"
        "        dummy: 'REDACTED x'\n"
    )
    proc = ws.run("encrypt", ws.write("bad.rsc", b"x\n"))
    assert proc.returncode != 0
    assert b"{masked}" in proc.stderr
