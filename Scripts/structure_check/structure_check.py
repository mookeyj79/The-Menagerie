#!/usr/bin/env python3
"""Check the sources of truth in Homelab Structure/ for broken references.

Usage:
    python Scripts/structure_check/structure_check.py [DIR]

DIR defaults to Homelab Structure/ at the repo root. Prints one line per
problem and exits 1 if there are any, 0 otherwise.

Interface:
    read_files(dir)    -> (files, errors)  files: {"systems.yml": <parsed>, ...}
    Structure(files)   -> resolved model; tests build one from inline YAML
    check(structure)   -> [str] problems, empty when sound

Group resolution follows the fw_groups.yml schema header: the union of
`members` (hostname short forms and `host:` long forms; CIDRs and IPs are
not hosts), `derive_from.vlan` (every system with an interface on one of
those VLANs) and `derive_from.role` (every system with that role, except
state: decommissioned).

Ported from the blog repo's HomelabInventory.ps1 (Test-Inventory), which
checked these files while they were copied there.
"""
import re
import sys
from pathlib import Path

import yaml

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_DIR = REPO_ROOT / "Homelab Structure"

CIDR_RE = re.compile(r"^\d{1,3}(\.\d{1,3}){3}(/\d{1,2})?$")

# Keys services.yml's schema header allows, per section ("" is the top level).
# A stale key such as vault: would otherwise slip past review.
SERVICE_KEYS = {
    "": {"name", "description", "state", "phase", "host", "stack", "depends_on",
         "integrations", "exposure", "notes"},
    "integrations": {"openbao", "stepca", "sso", "backup"},
    "exposure": {"dns_names", "via_proxy"},
}

# Systems allowed to sit in both RetroNet and a Management VLAN. None: RetroNet
# is untrusted (router3 and ap2 have no Management interface, blog issue #64).
RETRO_MGMT_EXCEPTIONS: set[str] = set()


def as_list(value):
    """A YAML scalar-or-list field as a list, without None entries."""
    if value is None:
        return []
    if isinstance(value, list):
        return [v for v in value if v is not None]
    return [value]


def read_files(directory):
    """Parse every YAML file under directory, keyed by its path below it."""
    directory = Path(directory)
    files, errors = {}, []
    if not directory.is_dir():
        return files, [f"Structure folder not found: {directory}"]
    paths = sorted(p for p in directory.rglob("*") if p.suffix in (".yml", ".yaml") and p.is_file())
    if not paths:
        errors.append(f"Structure folder holds no YAML files: {directory}")
    for p in paths:
        rel = p.relative_to(directory).as_posix()
        try:
            files[rel] = yaml.safe_load(p.read_text(encoding="utf-8"))
        except yaml.YAMLError as e:
            files[rel] = None
            errors.append(f"Structure file does not parse: {p.name}: {e}")
    return files, errors


def member_host(member):
    """The hostname a group member names, or None for a CIDR, an IP or a cidr: entry."""
    if isinstance(member, dict):
        return str(member["host"]) if member.get("host") else None
    if member is None:
        return None
    m = str(member)
    if "/" in m or CIDR_RE.match(m):
        return None
    return m


class Structure:
    """The sources of truth with names indexed and firewall groups resolved."""

    def __init__(self, files):
        def doc(name):
            d = files.get(name)
            return d if isinstance(d, dict) else {}

        def entries(d, key):
            return [e for e in as_list(d.get(key)) if isinstance(e, dict)]

        systems_doc = doc("systems.yml")
        self.files = set(files)
        self.systems = entries(systems_doc, "systems")
        self.system_groups = entries(systems_doc, "groups")
        self.vlans = entries(doc("vlans.yml"), "vlans")
        self.groups = entries(doc("fw_groups.yml"), "groups")
        self.rules = entries(doc("fw_rules.yml"), "rules")
        self.links = entries(doc("links.yml"), "links")
        self.services = entries(doc("services.yml"), "services")
        self.dns = doc("dns.yml")
        self.bastion = doc("bastion_access.yml")

        self.hostnames = {str(s.get("hostname")) for s in self.systems}
        self.vlan_names = {str(v.get("name")) for v in self.vlans}
        self.group_names = {str(g.get("name")) for g in self.groups}
        self.roles = {str(s["role"]) for s in self.systems if s.get("role")}
        self.routers = {str(s.get("hostname")) for s in self.systems if s.get("role") == "router"}

        self.group_hosts = {}
        for g in self.groups:
            hosts = []

            def add(h):
                if h and h not in hosts:
                    hosts.append(h)

            for m in as_list(g.get("members")):
                add(member_host(m))
            derive = g.get("derive_from")
            if isinstance(derive, dict):
                vlans = {str(v) for v in as_list(derive.get("vlan"))}
                roles = {str(r) for r in as_list(derive.get("role"))}
                for s in self.systems:
                    on_vlan = any(isinstance(i, dict) and str(i.get("vlan")) in vlans
                                  for i in as_list(s.get("interfaces")))
                    has_role = (bool(s.get("role")) and str(s["role"]) in roles
                                and str(s.get("state")) != "decommissioned")
                    if on_vlan or has_role:
                        add(str(s.get("hostname")))
            self.group_hosts[str(g.get("name"))] = hosts


def check(st):
    """Every broken reference in the Structure, one message each."""
    errors = []
    fail = errors.append

    for s in st.systems:
        for i in as_list(s.get("interfaces")):
            if isinstance(i, dict) and i.get("vlan") and str(i["vlan"]) not in st.vlan_names:
                fail(f"systems.yml: {s.get('hostname')} names unknown VLAN {i['vlan']}")

    for g in st.groups:
        derive = g.get("derive_from")
        if isinstance(derive, dict):
            for v in as_list(derive.get("vlan")):
                if str(v) not in st.vlan_names:
                    fail(f"fw_groups.yml: {g.get('name')} derives from unknown VLAN {v}")
            for r in as_list(derive.get("role")):
                if str(r) not in st.roles:
                    fail(f"fw_groups.yml: {g.get('name')} derives from role {r}, which no system has")
        for m in as_list(g.get("members")):
            name = member_host(m)
            if name and name not in st.hostnames:
                fail(f"fw_groups.yml: {g.get('name')} names unknown hostname {name}")

    for r in st.rules:
        for ref in as_list(r.get("src")) + as_list(r.get("dst")):
            ref = str(ref)
            if ref and ref != "any" and not CIDR_RE.match(ref) and ref not in st.group_names:
                fail(f"fw_rules.yml: {r.get('name')} names unknown group {ref}")
        for target in as_list(r.get("applies_to")):
            if str(target) not in st.routers:
                fail(f"fw_rules.yml: {r.get('name')} applies to {target}, which is not a router")

    # Port forwards: a dnat block sits on a forward-chain tcp/udp accept with
    # ports, above drop-unlisted-private (after dst-nat the destination is
    # private), and forwards to a known host that is a member of a dst group.
    drop_private_at = next((i for i, r in enumerate(st.rules) if r.get("name") == "drop-unlisted-private"), -1)
    for i, r in enumerate(st.rules):
        if "dnat" not in r:
            continue
        name, n = r.get("name"), r["dnat"]
        if r.get("chain") != "forward" or r.get("action") != "accept":
            fail(f"fw_rules.yml: {name} has dnat but is not a forward-chain accept")
        if str(r.get("protocol")) not in ("tcp", "udp") or not r.get("ports"):
            fail(f"fw_rules.yml: {name} has dnat but no tcp/udp ports")
        if not isinstance(n, dict) or not n.get("in_interface_list") or not n.get("to"):
            fail(f"fw_rules.yml: {name} dnat needs in_interface_list and to")
            continue
        to = str(n["to"])
        if to not in st.hostnames:
            fail(f"fw_rules.yml: {name} forwards to unknown hostname {to}")
        elif not any(to in st.group_hosts.get(str(d), []) for d in as_list(r.get("dst"))):
            fail(f"fw_rules.yml: {name} forwards to {to}, which is not a member of its dst")
        if drop_private_at >= 0 and i > drop_private_at:
            fail(f"fw_rules.yml: {name} has dnat but sits below drop-unlisted-private")

    for link in st.links:
        for end in (link.get("a"), link.get("b")):
            host = end.get("host") if isinstance(end, dict) else None
            if str(host) not in st.hostnames:
                fail(f"links.yml: link names unknown hostname {host}")
        for v in as_list(link.get("vlans")):
            if str(v) not in st.vlan_names:
                fail(f"links.yml: link names unknown VLAN {v}")

    # VM parents and system groups name real hosts.
    system_group_names = set()
    for g in st.system_groups:
        system_group_names.add(str(g.get("name")))
        for h in as_list(g.get("hosts")):
            if str(h) not in st.hostnames:
                fail(f"systems.yml: group {g.get('name')} names unknown hostname {h}")
    interfaces = {}
    for s in st.systems:
        if s.get("host") and str(s["host"]) not in st.hostnames:
            fail(f"systems.yml: {s.get('hostname')} runs on unknown host {s['host']}")
        interfaces[str(s.get("hostname"))] = {str(i.get("name")) for i in as_list(s.get("interfaces")) if isinstance(i, dict)}

    # DNS records: known domain, known host, an interface that host has, and a
    # CNAME target that is another record.
    domains = {str(d.get("name")) for d in as_list(st.dns.get("domains")) if isinstance(d, dict)}
    records = [r for r in as_list(st.dns.get("records")) if isinstance(r, dict)]
    record_names = {str(r.get("name")) for r in records}
    for r in records:
        name = r.get("name")
        for d in as_list(r.get("domains")):
            if str(d) not in domains:
                fail(f"dns.yml: {name} names unknown domain {d}")
        host = r.get("host")
        if host and str(host) not in st.hostnames:
            fail(f"dns.yml: {name} names unknown hostname {host}")
        elif host and r.get("interface") and str(r["interface"]) not in interfaces.get(str(host), set()):
            fail(f"dns.yml: {name} names interface {r['interface']}, which {host} does not have")
        if r.get("target") and str(r["target"]) not in record_names:
            fail(f"dns.yml: {name} targets unknown record {r['target']}")
        if r.get("split_horizon") and str(r["split_horizon"]) not in record_names:
            fail(f"dns.yml: {name} split-horizon names unknown record {r['split_horizon']}")
        if r.get("listed") and "narly.ninja" not in [str(d) for d in as_list(r.get("domains"))]:
            fail(f"dns.yml: {name} is listed but not a narly.ninja name")

    # Services run on a known host (or system group), depend on known services
    # and use only the keys in services.yml's schema header.
    service_names = {str(s.get("name")) for s in st.services}
    for s in st.services:
        for section, allowed in SERVICE_KEYS.items():
            mapping = s.get(section) if section else s
            if not isinstance(mapping, dict):
                continue
            prefix = f"{section}." if section else ""
            for k in mapping:
                if str(k) not in allowed:
                    fail(f"services.yml: {s.get('name')} has unknown key {prefix}{k}")
        for h in as_list(s.get("host")):
            if str(h) not in st.hostnames and str(h) not in system_group_names:
                fail(f"services.yml: {s.get('name')} runs on unknown host {h}")
        for d in as_list(s.get("depends_on")):
            if str(d) not in service_names:
                fail(f"services.yml: {s.get('name')} depends on unknown service {d}")

    # Bastion targets are firewall groups; identities belong to known identity groups.
    id_groups = [g for g in as_list(st.bastion.get("identity_groups")) if isinstance(g, dict)]
    id_group_names = {str(g.get("name")) for g in id_groups}
    identities = [e for e in as_list(st.bastion.get("identities")) if isinstance(e, dict)]
    for e in id_groups + identities:
        who = e.get("name") or e.get("user")
        for t in as_list(e.get("authorized_targets")):
            if str(t) not in st.group_names:
                fail(f"bastion_access.yml: {who} targets unknown firewall group {t}")
        for m in as_list(e.get("member_of")):
            if str(m) not in id_group_names:
                fail(f"bastion_access.yml: {who} is a member of unknown identity group {m}")

    # RetroNet is untrusted, so nothing may sit in both it and Management.
    for s in st.systems:
        legs = [str(i.get("vlan")) for i in as_list(s.get("interfaces")) if isinstance(i, dict)]
        bridges = any("retronet" in v for v in legs) and any(v.endswith("-management") for v in legs)
        hostname = str(s.get("hostname"))
        excepted = hostname in RETRO_MGMT_EXCEPTIONS
        if bridges and not excepted:
            fail(f"systems.yml: {hostname} has interfaces in both RetroNet and Management")
        if excepted and not bridges:
            fail(f"systems.yml: {hostname} no longer bridges RetroNet and Management; "
                 "remove it from RETRO_MGMT_EXCEPTIONS")

    return errors


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    directory = Path(argv[0]) if argv else DEFAULT_DIR
    files, errors = read_files(directory)
    errors += check(Structure(files))
    for e in errors:
        print(e)
    if errors:
        print(f"structure check: {len(errors)} problem(s) in {directory}", file=sys.stderr)
        return 1
    print(f"structure check: {len(files)} files, no broken references")
    return 0


if __name__ == "__main__":
    sys.exit(main())
