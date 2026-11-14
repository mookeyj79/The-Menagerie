#####################################
### Router 1 Configuration Script ###
### Version: 3.5                  ###
#####################################
### Changes from 3.4:
###  - Rotated Creds
#####################################

# Set Identity
/system/identity set name="Router1"

# Disable IPv6
/ipv6/settings set disable-ipv6=yes

# Create Admin User
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSB6NExXbzNweFprTkRIMVhOci80TTBZQTdJRXVTMkRUVm5QRGMvVWpYMTJVCjhpN0MxQ2htZis0Zjkyc2lScEtNeGpjRC9DQ1FrWnBtb2U3blE1UVVJckEKLT4gWDI1NTE5IDRUaCtla2thakQ0WUJ6cjIrQ0MwdTJnZnFIVjVoT2RPWnd3Z0c1S0F6U3cKeUpjakpqb2hjYkNUUEFoWHd5cmcvY0Z1OHBpRk15bUhqY2RjZ0pycGY4ZwotPiBwLWdyZWFzZQo0SkVHVWFoMnI2UnJ6TDBLQmF5dkpPZG9tdlp3dC8wWDRSNTJnVUpwT0JSVmlZMS9RVzlmNVc2VlZYb1lEZnpNCjdBVnA1M0VmVXhvWlNBd1JZa1BxNEFTU3pXYzd4dmFPQ0RSM05aYzBtWWRzY0NTUmNvMVRQaTMyY1F2MW9Cbm0KbDhzCi0tLSBLVmN5bGJCeWFUR3JKc2RWajZIcTFBcWRwU0JISFltb09vYkFSS1ZkSmVjCnYsf6591S6jfDtXITAsbDPlSAqxouIDiVG1mfkLgPuSEqkLHJoS98uW8cL3wljHIrshKCG_RppTiBZkgF_1VMAFUC_gUJXk-MiR0l2AodjdI2TlCi0
/user add name=REDACTED group=REDACTED password=REDACTED

# Enable NTP
/system/clock set time-zone-name=Etc/UTC
/system/ntp
client set enabled=yes servers=0.pool.ntp.org,1.pool.ntp.org,2.pool.ntp.org
server set enabled=yes

#  Create Bridges
/interface/bridge
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBxM3FRdS9wWVJ0VCtOMEdiSVRSMDRRZ1NHMG1tMjMwQnU3TEQ5S1RGZ2c0Cjh5akFHcGRVSm01eTV4bzhCL0JFb0FIRDhkM3NWQ1pXbjA1RmZ0T0QwZE0KLT4gWDI1NTE5IGNscXVXMk9zSjN3ODEwVUFVdmUvOWxYSG15N2NKWU5idVFxR2tqb0pLUXcKcTZjSzdaYU5lOUNyRE1oQkZ5Z0NWWDFLUCtHZ2E3TkxDbkRwUTczZXdTNAotPiAjJjtjeSQtZ3JlYXNlIEs5d35DQiAqN3hNKQp5MitBVWR3d0x5dDJYKytEdDZQNlJYZmFjbXlTMEJXME5sN2MxM0I0bWF5ZGI2YU1FUmw2NmdBRFNjRTJGSHlrCkc5RmZLQ1IwcWJyL3gxNTNLSldORkdzWjR6Vy9LMkdoeFROYjNnTy9yTFppMjR1SWpVdDNhQk9YdmFIOXcvZWoKOHlJCi0tLSA0MVFvSkp4bytBL0ZMMjlZZU5PRFQzTzdaQzRmLzZLcU96bVFoRXRYQXlvChJWNmCHTz6-l8aJc1k6QL5dh1u0Lh_nPIB_d72Lscw5qtGv09cGBC9W56SC-A-tf6XgLDPmuJYxaEZYuX2IxGmuZV3RZ7j4dkCkuvRzPMIIl4r_cIA0uuQ-7tcB56PeDg
REDACTED add name=external_bridge auto-mac=no admin-mac=00:00:00:00:00:00
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSA5dDZYRzNqd2NiTG9SYkxkS2kvRWRrUHZXcnkrN0Z4M1pOeWRxVmlCcEV3CkNEMXgwMndCR29HRHFhaEdWSG4wMmhnSXptVzlOMjI2dEh6ZVdjWElWVW8KLT4gWDI1NTE5IE5VS0w5RVluQy8wdWIxd2hSanNMTWxGSVlONmNpM1Vrc0xlWktJam9Za1kKWkhGUnpublVOTit1ZzNaZ2cvV0lCb0NuYkxpM1R2Q1dFU1RvZkVuTGlzTQotPiBtbVpgdHo2Li1ncmVhc2UgfSBXbCx1JiUKci93cU9yL3lzQ3ZxL1JYM2k0ZnhWQQotLS0gTUdzRlJSazdsVWRPbkk0K3Q2SFRGYTRyODk4aTFjQU1ZRXVTeTg2MjJhYwppZE4M857XkyA4cInp4TLtcLLok8wfomtr8ozi_pz-lkaQalYOY66Jl8J1CZOIwrAnH2b9ILn08pdE7AVpPKmnE-9jKEEnLW2rt4ljfrpKYrj9bPcWSnzeBPG-sovjoHE
REDACTED add name=arch1_bridge    auto-mac=no admin-mac=00:00:00:00:00:00
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSA5UThiU1ZnR2dCTHErLzM3blNpQ3R6cE5GeWlOZTlqNE9rekQwUTkyam13Cmd4R0dqbG80R1FoNEx2aUxycDFOTFJWazBwV3JuUXJhYnR2MXFvRmpvSW8KLT4gWDI1NTE5IHdZYjZQNnRQMnNQZWdZU0g4cUFwcG1MTzZ4VTZma1F5RUQ1OEN3TlBBbUkKTXNzQ1pvUE5HNzJKc1FiMlhFb3RWZ2NUOE1sUnY0a2lKV3VvUkpuUnFnOAotPiBALXglLWdyZWFzZSBXdSRyLn1eIFdXCks4Nm1rZVdFc1lXbm4xOAotLS0gWGdTYzFTbUFiU0hCbFlyQmlOR1QrcS9JclNFQXhUeXp4cnJmK3BhKy9ONArVtBASQt0Ir8yi4dS0XI8nlCujH5t6jUJER9wVJcYBoyJW_9E9_3IsDHMe2XnvTULk9yRo0KILdC-q1j6bDM6tCw-t2Ba1pJggocHXHYY2Tby0bt7LDo5sUZ8cIoWlz-s
REDACTED add name=arch2_bridge    auto-mac=no admin-mac=00:00:00:00:00:00
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBiZWEzTnRqQ004a1BGbzJGT3hIQ3dHQnVUN1ExamJWR3lCeTFaQ1hrMG1RCjREWnI2bGJRWEUweWxqc1p0V0FYRzZvZC9wTXBNdERhZnVkcWx1RURLRTAKLT4gWDI1NTE5IDAranV5aktrME5TUlFLdWNRcjJjNW5kb3RFSzlCWVZXT2EzQWkxNXNkWFEKU3hYZm91QTBETVRoOWlTczJRTy9WQ1BsenFxUElSUE11VkxiVXJ2bEJUMAotPiA3Y1JiLWdyZWFzZSBOTlkpZnQiIDU8d2ZaMSBJTmpBNGYmIFxMNUJZfjV6CgotLS0gb29KVVd0Y0NXNmhrMTNIem1DWkQrTW9memI2eFZKeUUyV0tjWFhEUk9zTQr2nl66LDG6zXSz9Z1TrSfGyheFTP5dRzYQPQODSDonv_d5BkzUxdJAKz-Y5MVK8ytOLiH37TJag2UmXW64C9KKS4YOA5_CXOe7K-yUngnfV1I3-TzmKMQGmEuM_yX7qSQ
REDACTED add name=dmz_bridge      auto-mac=no admin-mac=00:00:00:00:00:00
add name=loopback protocol-mode=none

# Setup DHCP Client
/ip/dhcp-client
add interface=external_bridge

# Create 'OFF The Bridge' access on Ether4
/interface/ethernet set ether4 name=emergency-access
/ip/address add interface=emergency-access address=10.8.11.1/29
/ip/pool add name=off-bridge ranges=10.8.11.2-10.8.11.6
/ip/dhcp-server/network add address=10.8.11.0/29 netmask=29 gateway=10.8.11.1 dns-server=10.8.11.1
/ip/dhcp-server add name=off-bridge interface=emergency-access address-pool=off-bridge lease-time=10m

# Create Interface VLANs
/interface/vlan
add name=VLAN4   interface=dmz_bridge   vlan-id=4   comment="DMZ - Servers"
add name=VLAN101 interface=dmz_bridge   vlan-id=101 comment="Hardware Management"
add name=VLAN102 interface=dmz_bridge   vlan-id=102 comment="Server Management"
add name=VLAN301 interface=arch1_bridge vlan-id=301 comment="Architecture-1"
add name=VLAN302 interface=arch2_bridge vlan-id=302 comment="Architecture-2"

# Assign IPs to VLANs/Bridges
/ip/address
add interface=VLAN4    address=192.168.4.1/26
add interface=VLAN101  address=10.0.1.1/28
add interface=VLAN102  address=10.0.2.1/28
add interface=VLAN301  address=192.168.3.1/30
add interface=VLAN302  address=192.168.3.5/30
add interface=loopback address=192.168.254.1/32

# Setup DNS
/ip/dns set servers=1.1.1.1,9.9.9.9 allow-remote-requests=yes

# Add Ports to Bridges
/interface/bridge/port
add interface=ether1 bridge=external_bridge
add interface=ether2 bridge=arch2_bridge pvid=4000
add interface=ether3 bridge=dmz_bridge   pvid=4000
add interface=ether5 bridge=arch1_bridge pvid=4000

# Bridge VLAN Tables
/interface/bridge/vlan
add bridge=arch2_bridge vlan-ids=302  tagged=arch2_bridge,ether2
add bridge=arch2_bridge vlan-ids=4000 tagged=arch2_bridge untagged=ether2

add bridge=dmz_bridge vlan-ids=4    tagged=dmz_bridge,ether3
add bridge=dmz_bridge vlan-ids=101  tagged=dmz_bridge,ether3
add bridge=dmz_bridge vlan-ids=102  tagged=dmz_bridge,ether3
add bridge=dmz_bridge vlan-ids=4000 tagged=dmz_bridge untagged=ether3

add bridge=arch1_bridge vlan-ids=301  tagged=arch1_bridge,ether5
add bridge=arch1_bridge vlan-ids=4000 tagged=arch1_bridge untagged=ether5

# Setup Interface Lists
## Create Lists
/interface/list
add name=LAN
add name=WAN
add name=Architecture
add name=Hardware_Management
add name=Server_Management

## Add Devices to Interface Lists
/interface/list/member
add interface=emergency-access list=Hardware_Management
add interface=VLAN101          list=Hardware_Management
add interface=VLAN102          list=Server_Management
add interface=external_bridge  list=WAN
add interface=VLAN4            list=LAN
add interface=VLAN301          list=Architecture
add interface=VLAN302          list=Architecture

# Secure Device
/ip/neighbor/discovery-settings set discover-interface-list=Hardware_Management
/tool/mac-server set allowed-interface-list=none
/tool/mac-server/mac-winbox set allowed-interface-list=Hardware_Management
/tool/mac-server/ping set enabled=no
/ip/service
set telnet disabled=yes
set ftp    disabled=yes
set www    available-from=10.0.1.0/28,10.0.1.16/28,10.0.1.32/28,10.8.11.0/29
set api    available-from=192.168.23.2
set winbox available-from=10.0.1.0/28,10.0.1.16/28,10.0.1.32/28,10.8.11.0/29
set ssh    available-from=10.0.1.0/28,10.0.1.16/28,10.0.1.32/28,10.8.11.0/29
/tool/bandwidth-server set enabled=no
/ip/proxy set enabled=no
/ip/socks set enabled=no
/ip/upnp  set enabled=no
# /ip/cloud set ddns-enabled=no update-time=no

# Setup Firewall
## Address Lists
/ip/firewall/address-list
add list=Architecture           address=192.168.3.0/30   comment="Architecture"
add list=Architecture           address=192.168.3.4/30
add list=Architecture           address=192.168.3.8/30
add list=DMZ_Servers            address=192.168.4.0/28   comment="DMZ - Servers"
add list=Internal_Servers       address=192.168.16.0/28  comment="Internal - Servers"
add list=Internal_Users         address=192.168.17.0/24  comment="Internal - Users"
add list=Internal_Guest_Network address=192.168.18.0/24  comment="Internal - Guest Network"
add list=Internal_Smart_Home    address=192.168.19.0/26  comment="Internal - Smart Home"
add list=Internal_Smart_Home    address=192.168.19.64/28
add list=Internal_Devices       address=192.168.20.0/26  comment="Internal - Devices"
add list=Internal_RetroNet      address=192.168.21.0/26  comment="Internal - RetroNet"
add list=Internal_Surveillance  address=192.168.22.0/28  comment="Internal - Surveillance"
add list=Internal_DevOps        address=192.168.23.0/29  comment="Internal - DevOps"
add list=Hardware_Management    address=10.0.1.0/28      comment="Hardware Management"
add list=Hardware_Management    address=10.0.1.16/28
add list=Hardware_Management    address=10.0.1.32/28
add list=Hardware_Management    address=10.8.11.0/29
add list=Hardware_Management    address=10.9.11.0/29
add list=Server_Management      address=10.0.2.0/28      comment="Server Management"
add list=Server_Management      address=10.0.2.16/28

add list=Admins address=192.168.17.2 comment="Admins"
add list=Admins address=192.168.17.3
add list=Admins address=192.168.17.7
add list=Admins address=192.168.17.8
add list=Admins address=192.168.17.9

add list=DevOps      address=192.168.23.2  comment="DevOps"

add list=Architecture   address=192.168.254.2/32 comment="Router2 loopback"
add list=MikrotikUpdates address=upgrade.mikrotik.com comment="RouterOS update checks"

/ip/firewall/filter
## Input Chain
add chain=input action=drop connection-state=invalid comment="Input Chain"
add chain=input action=drop protocol=udp dst-port=53 in-interface-list=WAN
add chain=input action=accept connection-state=established,related

add chain=input action=accept dst-address=127.0.0.0/8
add chain=input action=accept in-interface=loopback

add chain=input action=accept in-interface-list=LAN                protocol=udp dst-port=53,67,123

add chain=input action=accept src-address-list=Architecture        in-interface-list=Architecture        protocol=udp dst-port=53,123
add chain=input action=accept src-address-list=Hardware_Management protocol=tcp dst-port=22,80,443,8291
add chain=input action=accept src-address-list=Hardware_Management in-interface-list=Hardware_Management protocol=udp dst-port=53,123
add chain=input action=accept src-address-list=Server_Management   protocol=udp dst-port=53,123
add chain=input action=accept src-address-list=DevOps              protocol=tcp dst-port=8729

add chain=input action=accept protocol=icmp limit=5,10:packet
add chain=input action=accept protocol=ospf in-interface-list=Architecture

add chain=input action=add-src-to-address-list address-list=PortScanners address-list-timeout=1d protocol=tcp psd=21,3s,3,1
add chain=input action=drop src-address-list=PortScanners
add chain=input action=drop log=yes log-prefix="Dropped INPUT: "

## Forward Chain
### Default Traffic Settings
add chain=forward action=drop connection-state=invalid comment="Forward Chain"
add chain=forward action=accept connection-state=established,related

### Emergency Access
add chain=forward action=drop in-interface=emergency-access  comment="Emergency-Access"
add chain=forward action=drop out-interface=emergency-access

### Internet Access
add chain=forward action=accept src-address-list=Architecture           out-interface-list=WAN comment="Internet Access"
add chain=forward action=accept src-address-list=DMZ_Servers            out-interface-list=WAN
add chain=forward action=accept src-address-list=Internal_Servers       out-interface-list=WAN
add chain=forward action=accept src-address-list=Internal_Users         out-interface-list=WAN
add chain=forward action=accept src-address-list=Internal_Guest_Network out-interface-list=WAN
add chain=forward action=accept src-address-list=Internal_Smart_Home    out-interface-list=WAN
add chain=forward action=accept src-address-list=Internal_Devices       out-interface-list=WAN
add chain=forward action=accept src-address-list=Internal_RetroNet      out-interface-list=WAN
add chain=forward action=accept src-address-list=Internal_DevOps        out-interface-list=WAN
add chain=forward action=accept src-address-list=Server_Management      out-interface-list=WAN

### Hardware Management
add chain=forward action=accept src-address-list=Hardware_Management dst-address-list=Hardware_Management comment="Hardware Management"

### Server Management
add chain=forward action=accept src-address-list=Server_Management dst-address-list=Server_Management comment="Server Management"

### DMZ - Servers
add chain=forward action=accept src-address-list=Admins           dst-address-list=DMZ_Servers comment="DMZ - Servers"
add chain=forward action=accept src-address-list=Internal_Servers dst-address-list=DMZ_Servers
add chain=forward action=accept src-address-list=Internal_DevOps  dst-address-list=DMZ_Servers

### Internal - Servers
add chain=forward action=accept src-address-list=DMZ_Servers dst-address-list=Internal_Servers comment="Internal - Servers"

### RouterOS Update Checks (Router2 has no direct WAN, transits here)
add chain=forward action=accept src-address-list=Architecture dst-address-list=MikrotikUpdates protocol=tcp dst-port=443 out-interface-list=WAN comment="RouterOS Update Checks"

### Final Drop
add chain=forward action=drop log=yes log-prefix="Dropped FWD: " comment="Final Drop"

## Firewall NAT
/ip/firewall/nat
add action=masquerade chain=srcnat out-interface-list=WAN src-address=10.0.0.0/8
add action=masquerade chain=srcnat out-interface-list=WAN src-address=172.16.0.0/12
add action=masquerade chain=srcnat out-interface-list=WAN src-address=192.168.0.0/16

## Strict TCP Connection Tracking
/ip firewall connection tracking
set enabled=auto generic-timeout=10m icmp-timeout=10s loose-tcp-tracking=no \
    tcp-close-timeout=10s tcp-close-wait-timeout=10s tcp-established-timeout=1d \
    tcp-fin-wait-timeout=10s tcp-last-ack-timeout=10s tcp-max-retrans-timeout=\
    5m tcp-syn-received-timeout=5s tcp-syn-sent-timeout=5s \
    tcp-time-wait-timeout=10s tcp-unacked-timeout=5m udp-stream-timeout=3m \
    udp-timeout=10s

# Setup OSPF
/routing/ospf
instance add name=default vrf=main router-id=192.168.254.1 originate-default=always redistribute=connected
area add name=backbone instance=default area-id=0.0.0.0 type=default

/routing/ospf/interface-template
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBSanFQcTJJdjVwYzQxODdCSWdPT2NackZEWTZGK2JKeDB2QXdZVUtibFZ3CmRLS3JZalFkYUlPeTNVUk5uN2hwTjR3WSswY2JLQUFqVWowcEVleGI0SEkKLT4gWDI1NTE5IHV1UnNQZStYQXE3QnRvdThQMEt3WkFFb0tSM09qa0x3aTJiRkoxU0NSaDgKdzJ1eUVQNndNc3o5T3NNUGVSbFkwZTg1dHUyU25Ga1lQRmtoZE45SXVnVQotPiA-LWdyZWFzZQpiYU1MK3RJCi0tLSB3UVQ5WUoyVitwblRmbnZ5U2dCZmNLaW9DSTBlcERmUEJkekNHVWhEMUU0CsdepAIVsZz3YQo4bJEK5Y2sKCDnVoEPzlvF1__OZ___jc53_NVvoel5KUAAl5NgDPLPCx63jMcAINDhDHHdNgSsmCKikUuJFAOi3253bjSu_OO6oIoQIBR1kct7HNdog5kUZg3az9_mgfPmeqYSWlkw-WN4WZonVUE
/routing/ospf/interface-template add auth-key=REDACTED
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSA5TUg3WnYyME81bDUwTnl4MVJYWEtEcEtyQWMzaitlRGE0dzlzNmw4NUVJCjFUbGdITllQMkJkaS92elVIbWhaWEFjQlNvZjRydWEyYTBVUzF3L3FOeE0KLT4gWDI1NTE5IDBjRXpZSXh5R3l0MkxkcC8yZDBXdXIvbDVLbEMxVHRSRkFqNWIvUTJyMVkKTXJWa1pJKzE4OUhQK2lWKzF4cGlmK2FlRmJib1Y0UFJEeWgxOWlCcHdLZwotPiAici1ncmVhc2UgaGRjdCByI0YhQwplcTlGejMvMFYvV2Erdnlsb2V1b2NCdlZSWm5yeGxaSW94a1c1ODgwY1BocjhlMkxtaTgrdXZ1eC9qUUZlL1ZzCnVndFgySTAKLS0tICtmdWh2M05yQ1F5VmJNcHdqRXVVQUJXeHMrS2ozZHQ2enY3SFlhT1hHUkkK4h3xQjp1xKVfxiHAavE9i4eV8k7XisnXzH8_M0euKPYmtO2EgSZrK_a07PO6-QREIAU32_Qk4TxmknxXDPGGGdZ_xPq-P_tDKXifCCulDXcvPgeivL_Co8UbwMWtlLgh9WBhXswB3KJU_FUUDg2WpkY
/routing/ospf/interface-template add auth-key=REDACTED
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSAraEVNNFBLUWJaN1huNVJaUWU3L0VYekhwWm9RZFYzQ3BwelZZZjVXaDJjCmRoMVZKY08xYmx3QXJUTzkydkVoeUJnRitPQkoyQlNJOGhxUHlLUTllbGsKLT4gWDI1NTE5IDZ5d3g3b0Joei90Sm02U0k1anBESDJIU20xbkRPMmxYY0NwM1ZnUjZZd2sKdkhGczZwTkMrOEdXTjJxaEtKMFRNdmtvVUorRmtsdFBHeHNZYmF4UTlDOAotPiB6Wy1cVy1ncmVhc2UgQWteWF1SZSBOYgp4MUZFcUhHL0NCdXI3QW1telphS283RWkrREswTVJkWVlvRnY4WFdSVmxFRm5reCtIME9ONVJiNWdFVERRcGRMCjhTTVNXK2xRK1JSREVDTQotLS0gMzJxMmJoN2pQc1c0KzlNYlVZcTB4eWRIcm0zUUhSOHF5dnFwZzhaTHc5ZwoC-izaDhh-RlwGeqW_5huPWdwLyePzynLRwL6yd-RzQOtl3FCOXdIZ0tkz4aveeKn2iECGjF8-K2BkVIIi7ST0kZKNMO6SOgeGjseNUKmUrpGCYhQ5PlJipQ-IXPpVUHTI62Uourl-UCIgINvmfow6qQ
/routing/ospf/interface-template add auth-key=REDACTED
/routing/filter/rule
add chain=ospf-out rule="if (dst in 10.8.11.0/29) { reject }"
add chain=ospf-out rule="accept"

/routing/ospf/instance
set out-filter-chain=ospf-out numbers=default

# Enable Bridge VLAN Filtering
/interface/bridge
set arch1_bridge vlan-filtering=yes frame-types=admit-all
set arch2_bridge vlan-filtering=yes frame-types=admit-all
set dmz_bridge   vlan-filtering=yes frame-types=admit-all

/ip/dns/static
# Hardware Management
add name router0.mikewashere.man address 192.168.2.1
add name router1.mikewashere.man address 10.0.1.1
add name router2.mikewashere.man address 10.0.1.17
add name router3.mikewashere.man address 10.0.1.33
add name switch1.mikewashere.man address 10.0.1.2
add name switch2.mikewashere.man address 10.0.1.18
add name switch3.mikewashere.man address 10.0.1.34
add name switch4.mikewashere.man address 10.0.1.19
add name ap1.mikewashere.man address 10.0.1.20
add name ap2.mikewashere.man address 10.0.1.35
add name fw1.mikewashere.man address 10.0.1.3
add name fw2.mikewashere.man address 10.0.1.4
add name fw3.mikewashere.man address 10.0.1.21
add name fw4.mikewashere.man address 10.0.1.36

# Server Management
add name file1.mikewashere.man address 10.0.2.21
add name file1-idrac.mikewashere.man address 10.0.2.22
add name pve1.mikewashere.man address 10.0.2.18
add name pve2.mikewashere.man address 10.0.2.19
add name pve3.mikewashere.man address 10.0.2.20
add name pve4.mikewashere.man address 10.0.2.2
add name pve5.mikewashere.man address 10.0.2.3
add name pve6.mikewashere.man address 10.0.2.4
add name pve7.mikewashere.man address 10.0.2.5

# Power Managment
add name pdu1.mikewashere.man address 10.0.3.3

# DMZ - Servers
add name game1.mikewashere.lan address 192.168.4.2
add name ingress1.mikewashere.lan address 192.168.4.3
add name ntp1.mikewashere.lan address 192.168.4.4
add name seeder1.mikewashere.lan address 192.168.4.5
add name tunnel1.mikewashere.lan address 192.168.4.6

# Internal - Servers
add name bastion1.mikewashere.lan address 192.168.16.2
add name ca1.mikewashere.lan address 192.168.16.3
add name dc1.mikewashere.lan address 192.168.16.4
add name feeder1.mikewashere.lan address 192.168.16.5
add name file1.mikewashere.lan address 192.168.16.6
add name ingress2.mikewashere.lan address 192.168.16.7
add name ml1.mikewashere.lan address 192.168.16.8
add name nut1.mikewashere.lan address 192.168.16.9
add name secmon1.mikewashere.lan address 192.168.16.10
add name transcode1.mikewashere.lan address 192.168.16.11
add name vault1.mikewashere.lan address 192.168.16.12

# Internal - Smart Home
add name led-strip1.mikewashere.lan address 192.168.19.15
add name led-strip2.mikewashere.lan address 192.168.19.16
add name led-strip3.mikewashere.lan address 192.168.19.17
add name led-strip4.mikewashere.lan address 192.168.19.18

# Internal - Devices
add name printer1.mikewashere.lan address 192.168.20.2
add name printer2.mikewashere.lan address 192.168.20.3
add name printerfil1.mikewashere.lan address 192.168.20.4
add name printerfil2.mikewashere.lan address 192.168.20.5
add name printerres1.mikewashere.lan address 192.168.20.6
add name printerres2.mikewashere.lan address 192.168.20.7
add name laser1.mikewashere.lan address 192.168.20.8
add name cnc1.mikewashere.lan address 192.168.20.9
add name cutter1.mikewashere.lan address 192.168.20.10

# Internal - DevOps
add name devops1.mikewashere.lan address 192.168.23.2

# Services
## CA1
add name ca.mikewashere.lan address 192.168.16.3

## DevOps1
add name atlantis.mikewashere.lan address 192.168.23.2
add name awx.mikewashere.lan address 192.168.23.2
add name devops.mikewashere.lan address 192.168.23.2
add name gitlab.mikewashere.lan address 192.168.23.2
add name kestra.mikewashere.lan address 192.168.23.2
add name wud.mikewashere.lan address 192.168.23.2

## Feeder1
add name autobrr.mikewashere.lan address 192.168.16.5
add name bazarr-4k.mikewashere.lan address 192.168.16.5
add name bazarr-anime.mikewashere.lan address 192.168.16.5
add name bazarr.mikewashere.lan address 192.168.16.5
add name calibre.mikewashere.lan address 192.168.16.5
add name checkrr.mikewashere.lan address 192.168.16.5
add name dispatcharr.mikewashere.lan address 192.168.16.5
add name jdownloader.mikewashere.lan address 192.168.16.5
add name kapowarr.mikewashere.lan address 192.168.16.5
add name lidarr-flac.mikewashere.lan address 192.168.16.5
add name lidarr-mp3.mikewashere.lan address 192.168.16.5
add name maintainerr.mikewashere.lan address 192.168.16.5
add name picard.mikewashere.lan address 192.168.16.5
add name pinchflat.mikewashere.lan address 192.168.16.5
add name posterizarr.mikewashere.lan address 192.168.16.5
add name prowlarr.mikewashere.lan address 192.168.16.5
add name qbittorrent.mikewashere.lan address 192.168.16.5
add name qui.mikewashere.lan address 192.168.16.5
add name radarr-4k.mikewashere.lan address 192.168.16.5
add name radarr-anime.mikewashere.lan address 192.168.16.5
add name radarr.mikewashere.lan address 192.168.16.5
add name readarr-audiobooks.mikewashere.lan address 192.168.16.5
add name readarr-ebooks.mikewashere.lan address 192.168.16.5
add name sabnzbd.mikewashere.lan address 192.168.16.5
add name sonarr-4k.mikewashere.lan address 192.168.16.5
add name sonarr-anime.mikewashere.lan address 192.168.16.5
add name sonarr.mikewashere.lan address 192.168.16.5
add name spotweb.mikewashere.lan address 192.168.16.5
add name tautulli.mikewashere.lan address 192.168.16.5
add name wallabag.mikewashere.lan address 192.168.16.5
add name whisparr-4k.mikewashere.lan address 192.168.16.5
add name whisparr.mikewashere.lan address 192.168.16.5

## File1
add name influxdb.mikewashere.lan address 192.168.16.6
add name postgresql.mikewashere.lan address 192.168.16.6
add name nextcloud.mikewashere.lan address 192.168.16.6
add name redis.mikewashere.lan address 192.168.16.6
add name rustfs.mikewashere.lan address 192.168.16.6
add name syncthing.mikewashere.lan address 192.168.16.6

## Game1
add name amu.mikewashere.lan address 192.168.4.2
add name foundry.mikewashere.lan address 192.168.4.2
add name pelican.mikewashere.lan address 192.168.4.2
add name valheim.mikewashere.lan address 192.168.4.2
add name vrising.mikewashere.lan address 192.168.4.2

## Ingress1
add name adguard.ingress1.mikewashere.lan address 192.168.4.3
add name traefik.ingress1.mikewashere.lan address 192.168.4.3

## Ingress2
add name adguard.ingress2.mikewashere.lan address 192.168.16.7
add name traefik.ingress2.mikewashere.lan address 192.168.16.7
add name mikewashere.lan address 192.168.16.7
add name www.mikewashere.lan address 192.168.16.7

## ML1
add name chat.mikewashere.lan address 192.168.16.8
add name code.mikewashere.lan address 192.168.16.8
add name comfyui.mikewashere.lan address 192.168.16.8

## NUT1
add name peanut.mikewashere.lan address 192.168.16.9

## PrinterFil1
add name spoolman.mikewashere.lan address 192.168.20.4

## SecMon1
add name beszel.mikewashere.lan address 192.168.16.10
add name crowdsec.mikewashere.lan address 192.168.16.10
add name dozzle.mikewashere.lan address 192.168.16.10
add name frigate.mikewashere.lan address 192.168.16.10
add name grafana.mikewashere.lan address 192.168.16.10
add name speedtest.mikewashere.lan address 192.168.16.10
add name uptime.mikewashere.lan address 192.168.16.10

## Seeder1
add name audiobooks.mikewashere.lan address 192.168.4.4
add name ebooks.mikewashere.lan address 192.168.4.4
add name filestash.mikewashere.lan address 192.168.4.4
add name lubelogger.mikewashere.lan address 192.168.4.4
add name metube.mikewashere.lan address 192.168.4.4
add name music.mikewashere.lan address 192.168.4.4
add name pdf.mikewashere.lan address 192.168.4.4
add name photos.mikewashere.lan address 192.168.4.4
add name psitransfer.mikewashere.lan address 192.168.4.4
add name seerr.mikewashere.lan address 192.168.4.4
add name stash.mikewashere.lan address 192.168.4.4
add name tandoor.mikewashere.lan address 192.168.4.4
add name vaultwarden.mikewashere.lan address 192.168.4.4
add name wizarr.mikewashere.lan address 192.168.4.4

## Transcode1
add name jellyfin.mikewashere.lan address 192.168.4.11
add name plex.mikewashere.lan address 192.168.4.11
add name tdarr.mikewashere.lan address 192.168.4.11

## Vault1
add name vault.mikewashere.lan address 192.168.16.12

# Remove Default Admin User
/user remove admin
