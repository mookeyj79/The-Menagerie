"""Every audited secret shape and every MAC is protected (fake values only)."""
import pytest

RSC_SECRETS = [
    '/user add name=fakeadmin group=full password="fake pw"',
    "/routing/ospf/interface-template add networks=192.0.2.0/24 auth-key=FAKEKEY",
    '/interface/wifi/security add name=s1 authentication-types=wpa2-psk passphrase="fake pass phrase"',
    "/interface wireless security-profiles add name=p wpa2-pre-shared-key=FAKEPSK",
    "/snmp community add name=fakecommunity addresses=192.0.2.0/24",
    "/ppp secret add name=fakeppp password=FAKEPPP",
    "/interface wireguard add name=wg0 private-key=FAKEWGKEY",
    "/ip ipsec identity add peer=p1 secret=FAKEIPSEC",
    "/radius add address=192.0.2.5 secret=FAKERADIUS",
    "/tool e-mail set password=FAKEMAILPW",
    "/interface ethernet set ether1 mac-address=AA:BB:CC:00:11:22",
]

IOS_SECRETS = [
    "enable secret 9 $9$FAKEFAKEFAKE",
    "enable password 7 FAKE0822455D",
    "username fakewonka privilege 15 secret 9 $9$FAKEFAKEFAKE",
    "snmp-server community fakecommunity RO",
    " key-string FAKEKEYSTRING",
    "  key-hash ssh-rsa FAKEAAAAB3Nza",
    " ip ospf message-digest-key 1 md5 7 FAKE0834058A",
    " password 7 FAKE0822455D0A16",
    "crypto isakmp key FAKEPSK address 192.0.2.9",
    "tacacs-server host 192.0.2.7 key FAKETACACS",
    " mac address-table static aaaa.bbbb.cccc vlan 1 interface Gi0/1",
    " ip dhcp client-identifier aa-bb-cc-00-11-22",
]


@pytest.mark.parametrize("line", RSC_SECRETS)
def test_rsc_secret_shape_is_protected(ws, line):
    _check(ws, "s.rsc", line)


@pytest.mark.parametrize("line", IOS_SECRETS)
def test_ios_secret_shape_is_protected(ws, line):
    _check(ws, "s.ios", line)


def _check(ws, name, line):
    data = f"! keep me\n{line}\nkeep me too\n".replace("! keep", "# keep" if name.endswith("rsc") else "! keep").encode()
    enc = ws.encrypt(ws.write(name, data))
    assert line.encode() not in enc
    assert b"FAKE" not in enc.replace(b"REDACTED", b"") and b"fake" not in enc.split(b"confcrypt v2")[0]
    assert b"keep me too" in enc
    assert ws.decrypt_bytes(enc, name) == data


def test_plain_router_lines_are_left_alone(ws):
    data = b"/ip address add address=192.0.2.1/24 interface=ether1\n/ip dhcp-server add name=lan\n"
    assert ws.encrypt(ws.write("plain.rsc", data)) == data
