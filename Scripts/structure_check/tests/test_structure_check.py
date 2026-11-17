"""Tests for the structure check.

Each case changes one thing in a small inline Structure and expects one
message. The last tests run the real Homelab Structure/, so a broken
reference committed there fails CI.
"""
import copy
import subprocess
import sys
from pathlib import Path

import pytest
import yaml

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import structure_check as sc  # noqa: E402

# One document per file, small enough to read whole.
EXAMPLE = yaml.safe_load("""
systems.yml:
  systems:
    - hostname: router1
      role: router
      interfaces: [{name: lan, vlan: hardware-management, interface_lists: [WAN]}]
    - hostname: router2
      role: router
    - hostname: switch1
      role: switch
    - hostname: k3s-dmz1
      role: k3s-node
      interfaces: [{name: eth0, vlan: dmz}]
    - hostname: k3s-app1
      role: k3s-node
      interfaces: [{name: eth0, vlan: app-servers}]
    - hostname: pve1
      role: hypervisor
      interfaces: [{name: vmbr0, vlan: hardware-management}]
    - hostname: pve-old
      role: hypervisor
      state: decommissioned
    - hostname: ap2
      role: ap
      interfaces: [{name: wlan, vlan: retronet}]
    - hostname: vm1
      host: pve1
  groups:
    - name: k3s
      hosts: [k3s-dmz1, k3s-app1]
vlans.yml:
  vlans:
    - {id: 10, name: hardware-management}
    - {id: 20, name: dmz}
    - {id: 30, name: app-servers}
    - {id: 40, name: retronet}
fw_groups.yml:
  groups:
    - name: DMZ
      derive_from: {vlan: dmz}
    - name: Hypervisors
      derive_from: {role: hypervisor}
    - name: DevOps
      members:
        - k3s-app1
        - 10.0.5.0/24
        - 10.0.5.9
        - {host: router1, interface: lan}
        - {cidr: 10.0.6.0/24, comment: lab}
        - {fqdn: deb.debian.org, comment: Debian}
fw_rules.yml:
  rules:
    - name: devops-to-dmz
      src: DevOps
      dst: DMZ
      protocol: tcp
      ports: [22]
      action: accept
      chain: forward
      applies_to: [router1, router2]
    - name: drop-unlisted-private
      src: any
      dst: 10.0.0.0/8
      action: drop
      chain: forward
      applies_to: [router1]
links.yml:
  links:
    - a: {host: router1, port: ether1}
      b: {host: switch1, port: sfp1}
      vlans: [dmz]
dns.yml:
  domains:
    - name: narly.ninja
    - name: mikewashere.com
  records:
    - name: www
      domains: [mikewashere.com]
      host: k3s-dmz1
      interface: eth0
    - name: blog
      domains: [narly.ninja]
      target: www
      listed: true
    - name: www-internal
      domains: [mikewashere.com]
      host: k3s-dmz1
      split_horizon: www
services.yml:
  services:
    - name: blog
      host: k3s
      depends_on: []
      integrations: {openbao: false}
      exposure: {dns_names: [www]}
    - name: openbao
      host: pve1
      depends_on: [blog]
bastion_access.yml:
  identity_groups:
    - name: admins
      authorized_targets: [Hypervisors]
  identities:
    - user: mike
      member_of: [admins]
      authorized_targets: [DMZ]
""")


def structure(mutate=None):
    files = copy.deepcopy(EXAMPLE)
    if mutate:
        mutate(files)
    return sc.Structure(files)


def entry(items, key, name):
    return next(i for i in items if i[key] == name)


def system(f, hostname):
    return entry(f["systems.yml"]["systems"], "hostname", hostname)


def fw_group(f, name):
    return entry(f["fw_groups.yml"]["groups"], "name", name)


def add_forward(f, to, dst="DMZ", action="accept"):
    """A port forward just above drop-unlisted-private, where a valid one sits."""
    rules = f["fw_rules.yml"]["rules"]
    at = next(i for i, r in enumerate(rules) if r["name"] == "drop-unlisted-private")
    rules.insert(at, {"name": "test-forward", "src": "any", "dst": dst, "protocol": "tcp",
                      "ports": [443], "action": action, "chain": "forward",
                      "applies_to": ["router1"], "dnat": {"in_interface_list": "WAN", "to": to}})


def forward_below_drop(f):
    add_forward(f, "k3s-dmz1")
    rules = f["fw_rules.yml"]["rules"]
    rules.append(rules.pop(rules.index(entry(rules, "name", "test-forward"))))


def set_(path_fn, key, value):
    def mutate(f):
        path_fn(f)[key] = value
    return mutate


def test_example_passes():
    assert sc.check(structure()) == []


@pytest.mark.parametrize("group, hosts", [
    ("DMZ", ["k3s-dmz1"]),                 # derive_from.vlan
    ("Hypervisors", ["pve1"]),             # derive_from.role, decommissioned left out
    ("DevOps", ["k3s-app1", "router1"]),   # members: hostnames only, not CIDRs or IPs
])
def test_group_resolution(group, hosts):
    assert structure().group_hosts[group] == hosts


CASES = [
    # name, mutate, expected message fragment (None: must pass)
    ("firewall rule names unknown group",
     lambda f: f["fw_rules.yml"]["rules"][0].update(src="NoSuchGroup"),
     "unknown group NoSuchGroup"),
    ("firewall rule applies to a non-router",
     lambda f: f["fw_rules.yml"]["rules"][0].update(applies_to=["switch1", "router2"]),
     "switch1, which is not a router"),
    ("rule with every new field passes",
     lambda f: f["fw_rules.yml"]["rules"][1].update(
         action="fasttrack", family="ipv6", log=True, src_ports=[41641],
         connection_state=["established", "related"], out_interface_list="WAN"), None),
    ("rule with unknown action",
     lambda f: f["fw_rules.yml"]["rules"][0].update(action="reject"), "unknown action reject"),
    ("rule with unknown family",
     lambda f: f["fw_rules.yml"]["rules"][0].update(family="ipv5"), "unknown family ipv5"),
    ("rule with unknown connection state",
     lambda f: f["fw_rules.yml"]["rules"][0].update(connection_state=["closed"]),
     "unknown connection_state closed"),
    ("rule with a non-boolean log",
     lambda f: f["fw_rules.yml"]["rules"][0].update(log="yes"), "log must be true or false"),
    ("rule names an interface list one of its routers lacks",
     lambda f: f["fw_rules.yml"]["rules"][0].update(out_interface_list="WAN"),
     "out_interface_list WAN, which router2 does not have"),
    ("firewall group has an invalid fqdn",
     lambda f: fw_group(f, "DevOps")["members"].append({"fqdn": "deb debian org"}),
     "invalid fqdn deb debian org"),
    ("port forward to a host the dst derives by VLAN passes",
     lambda f: add_forward(f, "k3s-dmz1", "DMZ"), None),
    ("port forward to a host the dst derives by role passes",
     lambda f: add_forward(f, "pve1", "Hypervisors"), None),
    ("port forward to a decommissioned host of the role",
     lambda f: add_forward(f, "pve-old", "Hypervisors"),
     "pve-old, which is not a member of its dst"),
    ("port forward to a host outside its dst",
     lambda f: add_forward(f, "k3s-app1"), "which is not a member of its dst"),
    ("port forward to an unknown host",
     lambda f: add_forward(f, "hostX"), "forwards to unknown hostname hostX"),
    ("port forward on a drop rule",
     lambda f: add_forward(f, "k3s-dmz1", action="drop"), "is not a forward-chain accept"),
    ("port forward without ports",
     lambda f: (add_forward(f, "k3s-dmz1"), entry(f["fw_rules.yml"]["rules"], "name", "test-forward").pop("ports")),
     "has dnat but no tcp/udp ports"),
    ("port forward without a target",
     lambda f: (add_forward(f, "k3s-dmz1"), entry(f["fw_rules.yml"]["rules"], "name", "test-forward")["dnat"].pop("to")),
     "dnat needs in_interface_list and to"),
    ("port forward below drop-unlisted-private",
     forward_below_drop, "sits below drop-unlisted-private"),
    ("firewall group derives from unknown VLAN",
     lambda f: fw_group(f, "DMZ")["derive_from"].update(vlan="no-such-vlan"),
     "derives from unknown VLAN no-such-vlan"),
    ("firewall group derives from a role no system has",
     lambda f: fw_group(f, "Hypervisors")["derive_from"].update(role="nas"),
     "derives from role nas, which no system has"),
    ("firewall group names unknown hostname",
     lambda f: fw_group(f, "DevOps")["members"].append("hostX"),
     "DevOps names unknown hostname hostX"),
    ("system names unknown VLAN",
     lambda f: system(f, "k3s-dmz1")["interfaces"][0].update(vlan="no-such-vlan"),
     "k3s-dmz1 names unknown VLAN no-such-vlan"),
    ("VM runs on unknown host",
     lambda f: system(f, "vm1").update(host="pveX"), "vm1 runs on unknown host pveX"),
    ("system group names unknown hostname",
     lambda f: f["systems.yml"]["groups"][0]["hosts"].append("hostX"),
     "group k3s names unknown hostname hostX"),
    ("link names unknown hostname",
     lambda f: f["links.yml"]["links"][0]["a"].update(host="routerX"), "unknown hostname routerX"),
    ("link names unknown VLAN",
     lambda f: f["links.yml"]["links"][0].update(vlans=["no-such-vlan"]),
     "link names unknown VLAN no-such-vlan"),
    ("DNS record names unknown hostname",
     lambda f: f["dns.yml"]["records"][0].update(host="hostX"), "www names unknown hostname hostX"),
    ("DNS record names an interface its host lacks",
     lambda f: f["dns.yml"]["records"][0].update(interface="eth9"),
     "names interface eth9, which k3s-dmz1 does not have"),
    ("DNS record names unknown domain",
     lambda f: f["dns.yml"]["records"][0].update(domains=["example.org"]),
     "names unknown domain example.org"),
    ("DNS record targets unknown record",
     lambda f: f["dns.yml"]["records"][1].update(target="no-such-record"),
     "targets unknown record no-such-record"),
    ("DNS split-horizon names unknown record",
     lambda f: f["dns.yml"]["records"][2].update(split_horizon="no-such-record"),
     "split-horizon names unknown record no-such-record"),
    ("DNS listed name outside narly.ninja",
     lambda f: f["dns.yml"]["records"][0].update(listed=True),
     "www is listed but not a narly.ninja name"),
    ("service has unknown integration key",
     lambda f: f["services.yml"]["services"][0]["integrations"].update(vault=False),
     "has unknown key integrations.vault"),
    ("service has unknown top-level key",
     lambda f: f["services.yml"]["services"][0].update(ports=[80]), "has unknown key ports"),
    ("service runs on unknown host",
     lambda f: f["services.yml"]["services"][1].update(host="hostX"),
     "openbao runs on unknown host hostX"),
    ("service depends on unknown service",
     lambda f: f["services.yml"]["services"][0].update(depends_on=["no-such-service"]),
     "depends on unknown service no-such-service"),
    ("bastion targets unknown firewall group",
     lambda f: f["bastion_access.yml"]["identities"][0].update(authorized_targets=["NoSuchGroup"]),
     "mike targets unknown firewall group NoSuchGroup"),
    ("bastion identity in unknown identity group",
     lambda f: f["bastion_access.yml"]["identities"][0].update(member_of=["nobody"]),
     "member of unknown identity group nobody"),
    ("RetroNet device in Management",
     lambda f: system(f, "ap2")["interfaces"].append({"name": "mgmt", "vlan": "hardware-management"}),
     "ap2 has interfaces in both RetroNet and Management"),
]


@pytest.mark.parametrize("mutate, expect", [c[1:] for c in CASES], ids=[c[0] for c in CASES])
def test_case(mutate, expect):
    errors = sc.check(structure(mutate))
    if expect is None:
        assert errors == []
    else:
        assert len(errors) == 1 and expect in errors[0], errors


def test_missing_folder(tmp_path):
    files, errors = sc.read_files(tmp_path / "nope")
    assert files == {} and errors == [f"Structure folder not found: {tmp_path / 'nope'}"]


def test_unparseable_file(tmp_path):
    (tmp_path / "vlans.yml").write_text("vlans: [unclosed\n")
    _, errors = sc.read_files(tmp_path)
    assert len(errors) == 1 and errors[0].startswith("Structure file does not parse: vlans.yml")


def test_real_structure_is_sound():
    files, errors = sc.read_files(sc.DEFAULT_DIR)
    assert errors == []
    assert sc.check(sc.Structure(files)) == []


def test_cli_exit_codes(tmp_path):
    script = Path(sc.__file__)
    ok = subprocess.run([sys.executable, str(script)], capture_output=True, text=True)
    assert ok.returncode == 0, ok.stdout + ok.stderr
    for name, doc in EXAMPLE.items():
        (tmp_path / name).write_text(yaml.safe_dump(doc))
    links = yaml.safe_load((tmp_path / "links.yml").read_text())
    links["links"][0]["vlans"] = ["no-such-vlan"]
    (tmp_path / "links.yml").write_text(yaml.safe_dump(links))
    bad = subprocess.run([sys.executable, str(script), str(tmp_path)], capture_output=True, text=True)
    assert bad.returncode == 1
    assert bad.stdout.strip() == "links.yml: link names unknown VLAN no-such-vlan"
