#####################################
### Router 2 Configuration Script ###
### Version: 3.5                  ###
#####################################
### Changes from 3.4:
###  - Rotated Creds
#####################################

# Set Identity
/system/identity set name="Router2"

# Disable IPv6
/ipv6/settings set disable-ipv6=yes

# Create Admin User
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSAxZDc0blF1TlpZbnJLMkdSTDRWNDUrNDhBSCt4RXI3SXFHK0FCT0NTNUVFCnEvQ2E0L24ramFaU3REeTVpWG5IVi9pU29oWlJic0JhbUVUSnZ3SkpNbkUKLT4gWDI1NTE5IHJ2R1lYV1puNENPMGFwUHUxT01rdmFqdUVXeGp6ZUNoYSs4THM1SjJnekUKRFNMWDVoN2ZwKzZTWXBmRlVEYUltbi9HZ2hUNE01V0ViNDNtTGYwOURXRQotPiBDYURgLWdyZWFzZSA-RnNBJApDSWpES0xPbThFblBwVVJCZlNNcEV5aUZUeStaSXB1eDFURldQRWt3SEhvanc1UlVMZEUKLS0tIENveXk2dG1pK0tLL3JDZUZDblFJYjFVcGFkNXZSaHpLZnkzaXhaWEZxTkEKIvmkCe01fa6sWx19G2LUXgEIJngE4gUG4pOapbZlx59-jwhLldoZPRSM3NbcdUYyNNUT8nKaUJx2VhfYRnWCahNOAWlJvBrBcv_mwNCWO41gk2O0tg
/user add name=REDACTED group=REDACTED password=REDACTED

# Enable NTP
/system/clock set time-zone-name=Etc/UTC
/system/ntp
client set enabled=yes servers=192.168.3.1
server set enabled=yes

#  Create Bridges
/interface/bridge
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBzaHlxS2ljb2lmc3E5KzNiNjkxd0dibnIrT0lmT1ZvNFc0YXNzSjdlcG5jCnc4OGExL21jUWswKzloYytoWm5QVzBnbTM5ZFJ5K1cwTFlkeXV6MEEvVmcKLT4gWDI1NTE5IENLd3JwWkNPNzUrQmFna0tacVE2V1hKSk0zcXV5UzBDNklFWHo1VkVyMUEKN0lEZDEwMVlveU9uRi95WmdBVm5vcWNQS2IzMGMzN1pYREtvR0NSaXJ6VQotPiAsLWdyZWFzZSBtLDFiawowOFhaWmhLcHM3SlJhQmJjTEZWSjAzZmtVbkxzWDQwZElwOXNXZElWQXVBCi0tLSBsMHRZaUNCQWRMWkdVeU92czZQa0RUbFhkcVl4NU5BOEtoVDVPS0hrSk00Cip5GpbmE_5buqZdnD5JVlZDH4FEfvN-wlJT3FABcDtK5VliWhofmpPDmZ3dsmfxTW5dE1bf_B3dSECqiCARDouoVC8Zsy7s8FcfB_r-4euJY3lP7eNN-xwTLGnARraw6A
REDACTED add name=arch1_bridge    auto-mac=no admin-mac=00:00:00:00:00:00
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBaNmdGMmErTitMcnUzN2JjRy9rWE5XU3NkNFMzV0J4RUcvMmIzRkFaQ3k0CmFKSFM3c0FrbjBiNXNrY0lQcUJvZkVFKzh6Z0Q2emJDVXdMZXFtOWhkRDgKLT4gWDI1NTE5IExGZUdOdkVOcEFna3MvaHRPV3ozK3Mvbm1yQzZZRWhKeFdSaEd3WXRzd2sKNlNnYUFpUnp5b1RRNm5KbmlENzdKSlZ4NzlYc1ljY2dwQ2RXS0FyaXZLSQotPiA9fXpEZWgtZ3JlYXNlCmlpa0twMDk0Y0l5eUozVHRxdlZpbTNLdDJKRXUzTWZ6ZEVnUG5JN25IT1B1T2NIUy94RE8vY08rU0tlS2tQODcKbGxpZjdTbno4ODBxRENVCi0tLSBvdFJISXptQ0xCdkFPdEdCdzVCUE5HeG91K0lNbWR2alFtcHlJRXJNYTJrCjoo9hOT1eRoTcPijG-kh4GHMUbRE0sUive2vx367E_VexGqGfsrG6y768YvU-71zklgBeNmWAuSCIcv6USIK0HtYixwP_t6Q5hWp4ltBavT47rhAzVhp7J3eQgHWg_WrQ
REDACTED add name=arch3_bridge    auto-mac=no admin-mac=00:00:00:00:00:00
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBhVVd2SDVhbFB2dUkxTWdUSHJhZEpXcU04cXJuN0lHYUQ3bFRpeHBtMXhNClVhaFBHR2svZEk5dFU5aGJRbVF0VmFLZDl3U1dWbSswT0lZK08wNE9kbFUKLT4gWDI1NTE5IE1qVG5vbFRDNW4rdXBGMXZhdWN0Z3c4V3RIT3BIVmFkY0ZCQjlsZ0JwbVkKL3JDOHI0S3YxSHFZWlpndE5nTlloZjdkZVNKREhlelI3QzFqRmNObEVGYwotPiBsO1EjNS1ncmVhc2UgK15AWGoxIE84XXE5MyBcMCYhClZVT2wrcGpUejgxOTdhYnhNSXA4K1Noc29zbkUKLS0tIE1sNWUxWmgremdHK2JmTWlOK3pROXFqMkp1RTJCZU1MeTA5aERwT3ZWWUUKfLFqFxJUO5a4-0wwakGYMRb_jSjOIgv1JPjZY8QFHBzr4F4ab61vaHt-TU3KvlVGCfcgromjwvDKfWne6Y6IcF-WdkSQS_5s5L32KKgs0IG1z1UhpJvrVwqDqPPfSHoo
REDACTED add name=internal_bridge auto-mac=no admin-mac=00:00:00:00:00:00
add name=loopback protocol-mode=none

# Create 'OFF The Bridge' access on Ether5
/interface/ethernet set ether5 name=emergency-access
/ip/address add interface=emergency-access address=10.9.11.1/29 network=10.9.11.0
/ip/pool add name=off-bridge ranges=10.9.11.2-10.9.11.6
/ip/dhcp-server/network add address=10.9.11.0/29 netmask=29 gateway=10.9.11.1 dns-server=10.9.11.1 comment="OFF-Bridge"
/ip/dhcp-server add name=off-bridge interface=emergency-access address-pool=off-bridge lease-time=10m

# Create Interface VLANs
/interface/vlan
add name=VLAN16  interface=internal_bridge vlan-id=16  comment="Internal - Servers"
add name=VLAN17  interface=internal_bridge vlan-id=17  comment="Internal - Users"
add name=VLAN18  interface=internal_bridge vlan-id=18  comment="Internal - Guest Network"
add name=VLAN19  interface=internal_bridge vlan-id=19  comment="Internal - Smart Home"
add name=VLAN20  interface=internal_bridge vlan-id=20  comment="Internal - Devices"
add name=VLAN22  interface=internal_bridge vlan-id=22  comment="Internal - Surveillance"
add name=VLAN23  interface=internal_bridge vlan-id=23  comment="Internal - DevOps"
add name=VLAN101 interface=internal_bridge vlan-id=101 comment="Hardware Management"
add name=VLAN102 interface=internal_bridge vlan-id=102 comment="Server Management"
add name=VLAN103 interface=internal_bridge vlan-id=103 comment="Power Management"
add name=VLAN301 interface=arch1_bridge    vlan-id=301 comment="Architecture-1"
add name=VLAN303 interface=arch3_bridge    vlan-id=303 comment="Architecture-3"

# Assign IPs to VLANs/Bridges
/ip/address
add interface=VLAN16   address=192.168.16.1/28
add interface=VLAN17   address=192.168.17.1/24
add interface=VLAN18   address=192.168.18.1/24
add interface=VLAN19   address=192.168.19.1/26
add interface=VLAN20   address=192.168.20.1/26
add interface=VLAN22   address=192.168.22.1/27
add interface=VLAN23   address=192.168.23.1/29
add interface=VLAN101  address=10.0.1.17/28
add interface=VLAN102  address=10.0.2.17/28
add interface=VLAN103  address=10.0.3.1/29
add interface=VLAN301  address=192.168.3.2/30
add interface=VLAN303  address=192.168.3.9/30
add interface=loopback address=192.168.254.2/32

# Setup DNS
/ip/dns set servers=192.168.3.1,1.1.1.1,9.9.9.9 allow-remote-requests=yes

# Setup DHCP
## Create Pools
/ip/pool
add name=Pool_VLAN17  ranges=192.168.17.128-192.168.17.254
add name=Pool_VLAN18  ranges=192.168.18.10-192.168.18.254
add name=Pool_VLAN19  ranges=192.168.19.50-192.168.19.62
add name=Pool_VLAN20  ranges=192.168.20.50-192.168.20.62
add name=Pool_VLAN101 ranges=10.0.1.25-10.0.1.30
add name=Pool_VLAN102 ranges=10.0.2.25-10.0.2.30

## Classless static routes (RFC 3442) - Hardware Management only
## Route: 10.0.1.0/26 via 10.0.1.17 - covers all three Hardware
## Management /28s (Router1 .0/28, Router2 .16/28, Router3 .32/28)
## so clients keep cross-router reachability with no default gateway
/ip/dhcp-server/option
add name=hwmgmt-routes code=121 value=0x1A0A0001000A000111

## Create Networks
/ip/dhcp-server/network
add address=192.168.17.0/24 netmask=24 gateway=192.168.17.1 dns-server=192.168.17.1
add address=192.168.18.0/24 netmask=24 gateway=192.168.18.1 dns-server=192.168.18.1
add address=192.168.19.0/26 netmask=26 gateway=192.168.19.1 dns-server=192.168.19.1
add address=192.168.20.0/26 netmask=26 gateway=192.168.20.1 dns-server=192.168.20.1
add address=10.0.1.16/28    netmask=28 dhcp-option=hwmgmt-routes dns-server=10.0.1.17 comment="Hardware Management - no default route, see hwmgmt-routes"
add address=10.0.2.16/28    netmask=28 gateway=10.0.2.17    dns-server=10.0.2.17

## Create Servers
/ip/dhcp-server
add name=DHCP_VLAN17  interface=VLAN17  address-pool=Pool_VLAN17  lease-time=24h
add name=DHCP_VLAN18  interface=VLAN18  address-pool=Pool_VLAN18  lease-time=6h
add name=DHCP_VLAN19  interface=VLAN19  address-pool=Pool_VLAN19  lease-time=6h
add name=DHCP_VLAN20  interface=VLAN20  address-pool=Pool_VLAN20  lease-time=6h
add name=DHCP_VLAN101 interface=VLAN101 address-pool=Pool_VLAN101 lease-time=1h
add name=DHCP_VLAN102 interface=VLAN102 address-pool=Pool_VLAN102 lease-time=1h

# Add Ports to Bridges
/interface/bridge/port
add interface=ether1 bridge=arch1_bridge    pvid=4000
add interface=ether2 bridge=arch3_bridge    pvid=4000
add interface=ether3 bridge=internal_bridge pvid=4000

# Bridge VLAN Tables
/interface/bridge/vlan
add bridge=arch1_bridge vlan-ids=301  tagged=arch1_bridge,ether1
add bridge=arch1_bridge vlan-ids=4000 tagged=arch1_bridge untagged=ether1

add bridge=arch3_bridge vlan-ids=303  tagged=arch3_bridge,ether2
add bridge=arch3_bridge vlan-ids=4000 tagged=arch3_bridge untagged=ether2

add bridge=internal_bridge vlan-ids=16   tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=17   tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=18   tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=19   tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=20   tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=22   tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=23   tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=101  tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=102  tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=103  tagged=internal_bridge,ether3
add bridge=internal_bridge vlan-ids=4000 tagged=internal_bridge untagged=ether3

# Setup Interface Lists
/interface/list
add name=Architecture
add name=LAN
add name=Hardware_Management
add name=Server_Management
add name=Power_Management

## Add Devices to Interface Lists
/interface/list/member
add interface=emergency-access list=Hardware_Management
add interface=VLAN101    list=Hardware_Management
add interface=VLAN102    list=Server_Management
add interface=VLAN103    list=Power_Management
add interface=VLAN16     list=LAN
add interface=VLAN17     list=LAN
add interface=VLAN18     list=LAN
add interface=VLAN19     list=LAN
add interface=VLAN20     list=LAN
add interface=VLAN22     list=LAN
add interface=VLAN23     list=LAN
add interface=VLAN301    list=Architecture
add interface=VLAN303    list=Architecture

# Secure Device
/ip/neighbor/discovery-settings set discover-interface-list=Hardware_Management
/tool/mac-server set allowed-interface-list=none
/tool/mac-server/mac-winbox set allowed-interface-list=Hardware_Management
/tool/mac-server/ping set enabled=no
/ip/service
set telnet disabled=yes
set ftp    disabled=yes
set www    available-from=10.0.1.0/28,10.0.1.16/28,10.0.1.32/28,10.9.11.0/29
set api    available-from=192.168.23.2
set winbox available-from=10.0.1.0/28,10.0.1.16/28,10.0.1.32/28,10.9.11.0/29
set ssh    available-from=10.0.1.0/28,10.0.1.16/28,10.0.1.32/28,10.9.11.0/29
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
add list=Power_Management       address=10.0.3.0/29      comment="Power Management"

add list=Admins address=192.168.17.2 comment="Admins"
add list=Admins address=192.168.17.3
add list=Admins address=192.168.17.7
add list=Admins address=192.168.17.8
add list=Admins address=192.168.17.9

add list=DevOps      address=192.168.23.2  comment="DevOps"
add list=CAs         address=192.168.16.3  comment="CAs"
add list=FileServers address=192.168.16.6  comment="File Servers"
add list=Ingress     address=192.168.4.3   comment="Ingress"
add list=Ingress     address=192.168.16.7
add list=Vaults      address=192.168.16.12 comment="Vaults"
add list=Printers    address=192.168.20.2  comment="Printers"
add list=Printers    address=192.168.20.3
add list=CNCs        address=192.168.20.4  comment="CNC"
add list=CNCs        address=192.168.20.5
add list=CNCs        address=192.168.20.6
add list=CNCs        address=192.168.20.7
add list=CNCs        address=192.168.20.8
add list=CNCs        address=192.168.20.9
add list=CNCs        address=192.168.20.10
add list=LEDs        address=192.168.19.15 comment="LEDs"
add list=LEDs        address=192.168.19.16
add list=LEDs        address=192.168.19.17
add list=LEDs        address=192.168.19.18

add list=Sunshine_Sources address=192.168.17.3 comment="Sunshine"
add list=Sunshine_Sources address=192.168.17.4
add list=Sunshine_Sources address=192.168.17.5
add list=Sunshine_Sources address=192.168.17.7
add list=Sunshine_Sources address=192.168.17.8
add list=Sunshine_Sources address=192.168.17.9
add list=Sunshine_Targets address=192.168.19.30
add list=Sunshine_Targets address=192.168.19.31
add list=Sunshine_Targets address=192.168.19.66

## Firewall Filters
/ip/firewall/filter

## Input Chain
add chain=input action=drop connection-state=invalid comment="Input Chain"
add chain=input action=accept connection-state=established,related

add chain=input action=accept dst-address=127.0.0.0/8
add chain=input action=accept in-interface=loopback

add chain=input action=accept in-interface-list=LAN                protocol=udp dst-port=53,67,123

add chain=input action=accept src-address-list=Architecture        in-interface-list=Architecture        protocol=udp dst-port=53,123
add chain=input action=accept src-address-list=DevOps              in-interface=VLAN23                   protocol=tcp dst-port=8729
add chain=input action=accept src-address-list=Hardware_Management protocol=tcp dst-port=22,80,443,8291
add chain=input action=accept src-address-list=Hardware_Management in-interface-list=Hardware_Management protocol=udp dst-port=53,123
add chain=input action=accept src-address-list=Server_Management   protocol=udp dst-port=53,123
add chain=input action=accept src-address-list=Power_Management    protocol=udp dst-port=53,123

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
add chain=forward action=accept src-address-list=Internal_Servers       out-interface-list=Architecture comment="Internet Access"
add chain=forward action=accept src-address-list=Internal_Users         out-interface-list=Architecture
add chain=forward action=accept src-address-list=Internal_Guest_Network out-interface-list=Architecture
add chain=forward action=accept src-address-list=Internal_Smart_Home    out-interface-list=Architecture
add chain=forward action=accept src-address-list=Internal_Devices       out-interface-list=Architecture
add chain=forward action=accept src-address-list=Internal_RetroNet      out-interface-list=Architecture
add chain=forward action=accept src-address-list=Internal_DevOps        out-interface-list=Architecture
add chain=forward action=accept src-address-list=Server_Management      out-interface-list=Architecture

### Hardware Management
add chain=forward action=accept src-address-list=Hardware_Management dst-address-list=Hardware_Management comment="Hardware Management"
add chain=forward action=accept src-address-list=Internal_DevOps     dst-address-list=Hardware_Management

### Server Management
add chain=forward action=accept src-address-list=Server_Management dst-address-list=Server_Management comment="Server Management"
add chain=forward action=accept src-address-list=Internal_DevOps   dst-address-list=Server_Management

### Internal - Servers
add chain=forward action=accept src-address-list=Admins          dst-address-list=Internal_Servers comment="Internal - Servers"
add chain=forward action=accept src-address-list=Internal_DevOps dst-address-list=Internal_Servers

### Internal - Devices
add chain=forward action=accept src-address-list=Admins          dst-address-list=Internal_Devices comment="Internal - Devices"
add chain=forward action=accept src-address-list=Internal_DevOps dst-address-list=Internal_Devices

### Internal - DevOps
add chain=forward action=accept src-address-list=Admins dst-address-list=Internal_DevOps comment="Internal - DevOps"

### CAs - Bootstrap
add chain=forward action=accept src-address-list=DMZ_Servers       dst-address-list=CAs protocol=tcp dst-port=443 comment="CAs"
add chain=forward action=accept src-address-list=Internal_Users    dst-address-list=CAs protocol=tcp dst-port=443
add chain=forward action=accept src-address-list=Internal_Devices  dst-address-list=CAs protocol=tcp dst-port=443
add chain=forward action=accept src-address-list=Internal_DevOps   dst-address-list=CAs protocol=tcp dst-port=443
add chain=forward action=accept src-address-list=Server_Management dst-address-list=CAs protocol=tcp dst-port=443
add chain=forward action=accept src-address-list=CAs dst-address-list=Internal_Devices  protocol=tcp dst-port=80
add chain=forward action=accept src-address-list=CAs dst-address-list=Internal_DevOps   protocol=tcp dst-port=80
add chain=forward action=accept src-address-list=CAs dst-address-list=Server_Management protocol=tcp dst-port=80

#### File Servers - Bootstrap
add chain=forward action=accept src-address-list=Internal_Users   dst-address-list=FileServers protocol=tcp dst-port=139,445,5357,5358 comment="File Servers"
add chain=forward action=accept src-address-list=Internal_Users   dst-address-list=FileServers protocol=udp dst-port=137,138,3702
add chain=forward action=accept src-address-list=DMZ_Servers      dst-address-list=FileServers protocol=tcp dst-port=9000
add chain=forward action=accept src-address-list=Internal_Devices dst-address-list=FileServers protocol=tcp dst-port=9000

### Vault - Bootstrap
add chain=forward action=accept src-address-list=Admins           dst-address-list=Vaults protocol=tcp dst-port=8200 comment="Vaults"
add chain=forward action=accept src-address-list=DMZ_Servers      dst-address-list=Vaults protocol=tcp dst-port=8200
add chain=forward action=accept src-address-list=Internal_Devices dst-address-list=Vaults protocol=tcp dst-port=8200
add chain=forward action=accept src-address-list=Internal_DevOps  dst-address-list=Vaults protocol=tcp dst-port=8200

### Ingress
add chain=forward action=accept src-address-list=Ingress        dst-address-list=Ingress comment="Ingress"
add chain=forward action=accept src-address-list=Internal_Users dst-address-list=Ingress

### Printers
add chain=forward action=accept src-address-list=Internal_Users         dst-address-list=Printers comment="Printers"
add chain=forward action=accept src-address-list=Internal_Guest_Network dst-address-list=Printers

### CNCs
add chain=forward action=accept src-address-list=Internal_Users dst-address-list=CNCs comment="CNCs"

### LEDs
add chain=forward action=accept src-address-list=Internal_Users dst-address-list=LEDs comment="LEDs"

### Sunshine
add chain=forward action=accept src-address-list=Sunshine_Targets dst-address-list=Sunshine_Sources dst-port=47984,47989,48010 protocol=tcp comment="Sunshine"
add chain=forward action=accept src-address-list=Sunshine_Targets dst-address-list=Sunshine_Sources dst-port=5353,47998-48010 protocol=udp

### Final Drop
add chain=forward action=drop log=yes log-prefix="Dropped FWD: " comment="Final Drop"

# Strict TCP Connection Tracking
/ip firewall connection tracking
set enabled=auto generic-timeout=10m icmp-timeout=10s loose-tcp-tracking=no \
    tcp-close-timeout=10s tcp-close-wait-timeout=10s tcp-established-timeout=1d \
    tcp-fin-wait-timeout=10s tcp-last-ack-timeout=10s tcp-max-retrans-timeout=\
    5m tcp-syn-received-timeout=5s tcp-syn-sent-timeout=5s \
    tcp-time-wait-timeout=10s tcp-unacked-timeout=5m udp-stream-timeout=3m \
    udp-timeout=10s

# Setup OSPF
/routing/ospf
instance add name=default vrf=main router-id=192.168.254.2 redistribute=connected
area add name=backbone instance=default area-id=0.0.0.0 type=default

/routing/ospf/interface-template
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSA4Z2RHUXFUdXR4VEQ2eHpPb2tuZ0d5SUxpemZjRE5DeW9nUXZ6L2s2Y1hjCmpKa0hJWjZVbVJMV0N5T0hwTlB0MlVKZ0VpZjg2SVNPNzB4WkRJbTF6K00KLT4gWDI1NTE5IDQ5WXNvZGZRS1gySHhlWEpjMWlRbzdxOXh6OEhBdWhRZDNEbzhkeUhORGsKYURhdXpzUXRXYzlIWmtpQjg1ejZqa1R4Tlo0cGl1NGlEMGdKQ245NEtFbwotPiBcNS1ncmVhc2UgLSkgNHwKN1ZtdXRXREFheWFoVUNtWjZ3Ci0tLSBTSkxmTGtFVlFxRDVaRm9aZVhBUzZEaldYNnhzajlIdE9GUVkyaVlBdU1zCh-TUtHsMCRS28eIZH8j0wqOUuaJTvcncv28eIgSXhbIo1UUAJ7AB7y1Er4J_16ORHh87PILsHPqwkvPWytTqC15rMYqDZ1lpLDpLSTPD2ULSgeiq488dVD20KdNqaVjLKDX17do9-z4Uzoe9tnwBHIsgKZ_YpgOOoY
/routing/ospf/interface-template add auth-key=REDACTED
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBrUEVraTNUZ1kvUmo0VENITFdvckhhWTFsbVpEVDRiOGhIWmJNQSswQXdFClVzL3V2OEREaFYxUWpQdTcwVk9FNklsWS9rUmhxNmlDMTZ6em05ZGRUd0EKLT4gWDI1NTE5IHRpN0dtZWI2QXBueUFEMERlMzFxaW1KMVJyTDR4VjRXU3o3VVlSdVM2VzAKSENRcHdZREVXT1RSa2krbytrb3pLd3J3b2p3VklKb1p6cVhtbWF5L0dzVQotPiAvXnk5UDBTLy1ncmVhc2UgPD9iY10geTAnIigKY0RjT2lUa2ZJU0Riem1jdHVIUmp6czdWTjlLd3RseVdxMmZSODIzUld0amVuN2QyZEF5aWRhelJYUkxFVTczagp2VTVSRklXc2Q4bE5NY091WFVZb0ttbwotLS0gSjVWd0I2SmJVa1B4cHNSSm4vY2xlM0cyVzBUdkhzWWd5TnQ2NktNK09mcwrJL1Vy0Bq5sJLqezGiArJ2EEs6GoJfQrUZn2Aq1L1txOdnX-RUoBBz7g61j83TuIONc1an2-QAsWM4aI45qsTI2V90NgwC4yfxWZYj0jO8ee4yQCj9t4qDUz0QuDKvJd_Cl9n3lzksMgFe5RDM1FPC
/routing/ospf/interface-template add auth-key=REDACTED
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBwR2NEVUdseUM3Rlo3TFVZc3RiTEZGaDNBOTNaaE9hZ3VJMUV5TUxIT1FrCjFHQlRHV29ZVjhxMXRYb2VnTGJPMGdEUXVYeFAvRkFaUGtpQXVkajd6aE0KLT4gWDI1NTE5IGVjN244TzBOSHA4Zk1vc1N5SUliZEdkaGVOa1EyNWd6b0paSTlDcy9ubkEKbEhmWnNQRlpLeCtpdFY2bEJLSndxeGRyRXpIWTl4dmtBRlI2WDh0RWdBZwotPiA5dlNvXS1ncmVhc2UgVnkgeE85CjNoTQotLS0gUVZuNEpRdmwrV1FTdG12Z3VnZUc2QTl2NGdXeEtNamYzdG5HMi9vc2dtawqK9xawFWaisnZ0IifijUco2Q-IW5aW46I564fod-xfguy3GtiB_tmZnqjb6ie1oG4ERwn7IeYX7Ot0ElSHCuxBWgsbV3F4W2MtF2fF6kIJqAdgcL5fNfQ-zJjwwVAB5owTGEJMC2LB7VcT_Ys5oIjo
/routing/ospf/interface-template add auth-key=REDACTED

/routing/filter/rule
add chain=ospf-out rule="if (dst in 10.9.11.0/29) { reject }"
add chain=ospf-out rule="accept"

/routing/ospf/instance
set out-filter-chain=ospf-out numbers=default

# Enable Bridge VLAN Filtering
/interface/bridge
set arch1_bridge    vlan-filtering=yes frame-types=admit-all
set arch3_bridge    vlan-filtering=yes frame-types=admit-all
set internal_bridge vlan-filtering=yes frame-types=admit-all

# DHCP Server Leases
/ip/dhcp-server/lease

## Internal - Users ###
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBQYjl4WmJPYXl1NUdteFhJdTdaQ0ZEeFJsRU9wTVZ2UHpZUUEzSGd1MzI4ClRIcjg2aFRZVXBBS0svVGIwdnFmdEw5d1N2ZTN4N3k0VkdIeWFNK2JOMTgKLT4gWDI1NTE5IDh3R1h2bmZGNGNzRmhlb1JLczF0Q3pTQ1N6NUNzeDVYVmRNczlJZXJXME0KVTJ5eWdmV2l5RktuU2JQakVyN3RuckEwVE1NTjIwUmlMZEhVQVFwRUhIdwotPiBzdDwtZ3JlYXNlClNIUU5zd0I0RlJWcy9OQ0plWHNhNnBTQnhOOTVnZ2VySnJlZE5pSkt1K05aR2plc0tqWEVzcTdJZ2JJeDM5N1AKUDRkUHY2T2ZmT211WUNLOEttOWcyZTRHL2RYWWtBCi0tLSB1MjlzM05UK0ZTd1J3Y0ZqRmxldFNoYUZWWU9SNHBXdXVQc2E0NW9yV2lNCrkKnq3rG5KarXkmggpSfsXTLnKtFnCLmpm2NBjXStN72oSEDLt0Z1eIa4KPMfnu-RE6C4-85MPGhuR173WuFQlhemCLTG1DFSlaub7nJbYtVNvi5-vuFy8n96w8iU2a1480J01Kvs6TucT3YUzT-JYKhnhHe9ZOQV74u-ydER2kZ70EmWrkaPRWVLaW-6w
REDACTED add address=192.168.17.2 comment="Andy"                       mac-address=00:00:00:00:00:00 server=DHCP_VLAN17
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBDV0lNNVIyaU02RUlLZ0dMem1KYjJhT1BXM2x0ckw0ME1YUDNmN2FoM0RjCjhJUytOY1FGVXdMdXFONGNTUWFyNVJsQlRUc3FiNEhmREp1aUhJbnlQRncKLT4gWDI1NTE5IE1obWo5MjJva0E4Uy90Z1BPSlNudXA5TEZCZVEyMG04R2R5T0NpUVN6V2cKemVPNGRNOExJeG9FQVNJbGozcXhGUTFKREt1L0l4VVBKZ3ByQXJjNFh5ZwotPiAsT3MtZ3JlYXNlIFNAbwo0bDd2TUducEdhem92SysrY1hPUmNWSUppWS8ybEM4Ci0tLSA5L2tEUUJZYmFPYkUwbDdTU05MTEhFZm5kZUQ0eTVuQmVGMGVHRllRd3RNCtYAVzEKu0ONZGzZiMrGk02BQWBqx1ySrw4rVZ3dMSSTVwnIKNltCpo6jLy17_L-NzoBXCmda7CJ6AQ7tKBZHN9rTEDHHr6SXHU_pq4ry3p5TnPTyvPokqdTlO5cAXmvcltvtBB6dsxzJ8NbbOaRNRv6WAvUUiA-DhQhi3KFEukSo5rrpwdXWPTpwYYrsUk
REDACTED add address=192.168.17.3 comment="Desky (Ethernet)"           mac-address=00:00:00:00:00:00 server=DHCP_VLAN17
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBlTzhndDBBZUsvMFhWeTNoRGtwbE80NS9mWGV6NHgyQ1NINFUwREl4SGdnCmFVVzVESXlMVUFkWHpEclhESDkxYVM4eGFVSWlzdFI0L055cndlVWJkazgKLT4gWDI1NTE5IEpDSmNMaFhjK2lzcDNseTkvb1J2eUtyMTRJeExMb1dCWGRReEc4WDBMVW8KdnBhT0ZSc0RGbE1VTjVHeFNlU1VNNTJsTjk3Y2ZIb0VmMGMrOVF4dW52cwotPiA2QHkoLWdyZWFzZSA0ZGdOcGE4IDxzUjQKQXZ2eGdqMEpEN3lHMEQ4S1l2cEFaZXBtMkFoaTBnTGlOVm1DUzBGSUpiNHptMzRpbDRGYVlBRkY5WmRhSXlOYQpKcEhtYXJEWFk0bVNNc0JIMTlMUjBjWUprSkZNaFNJYksxRXhVNjdrVmcKLS0tIC93UEd4dmJHNURNNmp1MmlyZndMOVE3Zi8yMTNrbmUyUk5mSXBTbjYzSWMKDYS7bJkvkGs2lGb4aUHRacIaOQDEaKei2Is65WQMVcU436YEqkGtpfZGmGyYZGOzaf3VfVRvPAQZTOf1rp6wqenNAyfUQaN8CBwxc_S7u4qvqmAc9Gt5ls6MoGdznuB2WxQPhA2wzatbcx1aRkwthnyt5tM2jS3EA-xCU_kixZqpbw4LBxb-6CLxR8EIzg
REDACTED add address=192.168.17.4 comment="KellysKomputer (Ethernet)"  mac-address=00:00:00:00:00:00 server=DHCP_VLAN17
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSAwRlpwajlLWmFrRjNYOTl6NThVbWRvT2FvUmgwdFZENXRHVXB4Unk4YXlNCkRHZ2cwSGVUVzhWc1Jtd2YxWjVsZWMySHE1U01kYzBHRjFLTGlqQkwzNU0KLT4gWDI1NTE5IEpkK3pscjI0UmRtQVpTZ2JvYVVDNWZYM2tXS1d2WjI5eEY2Wi9vZThqbmsKNVpKMmxCc3c1eWw2WUpxUEtDUWpwQkNIdm9LSVh4ZjdKRDR3bElZd09ERQotPiA3LWdyZWFzZQpDaHZmakpLNGRKclNaMTFGK2RiUjNhUkVrWEpVUno4L0NKSHg0T2NiU1EKLS0tIDZWNkRmbityRGFXS2RPSHlIc0RudkdmVHhLWFVnajVHdk1icWxURjA2VlkK1Onav_g095NdYlNPm37P9_pq2NVcTvG0MhCIpowBnwfYzcgAmkBH-O2SmkLzhVFAgpmXNn_wpH_766hhsTdrDVgYMjG_6Wen3RT_-RrximtH51nzKZS0s7WVgceRhM_AnuL_MMAEppp_1rthrNwmRnlyuIe72Ae3b92lNQ7xexpixj1uu8bexoZTZ9jX9g
REDACTED add address=192.168.17.5 comment="KellysKomputer (WiFi)"      mac-address=00:00:00:00:00:00 server=DHCP_VLAN17
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBrR0M2WlZLcDAwZ1ZRNThCTkdGbWJMNEZoSEZCK0RHRGNJaitRUGNNNWo0Cko2aHR0MERaaEpZbkRuTHhkeE1nakJvNzdISHU0WTFBaTZad05LMlg2NG8KLT4gWDI1NTE5IHJXWnVyOVBwK3dzTkx2b0pRamRWVm9pQ2tvcG1EYm04K2YzcXpWRS84ekUKcHFPVjcwb21LLzVCUERUdjdtQ3l3K2NKa3pkTGt6dGF6Qk90dWEzZEhlWQotPiBUY2VRaC1ncmVhc2UgLzR0K3ogfGpAPUVkZgpQMER3S25oSXQvOEhLN1Q4VU5CSHJkVlZsWnZ0dzkweVNBOGtkbmV3czFVc053MkxHWWR3bWRwUXhkWkdhdjRyCkFURVF3d2VzNDZwdlZNc1UvQXBOamJrNG01UHBEbUVRVjZ1bU1OQ05IK1VBbmpTZWhXVjYKLS0tIHFTUm5PTUxSem8yU0ZVUFBIWUl5c1NueGpIUDRQOFFGb0wxNWF1MUxLaW8KvHxI38YZrwYhIqrwoFe-E0Ey9w3FEtzHhQ_NrTs1bDZf2y04wMhTpC1OBic2CwuvA7iCb_2xyFJWN2dwnjPnP4EcgcToQZenc4D2LVbecdXmNQ13pwbHE-1MC5rOTswWyxVvwJCfT-zE9IdFxhmeak-PqOUYh3J0wvBooemqTO6W7nMrtn-d_xV6Y2r-_w
REDACTED add address=192.168.17.6 comment="KellysPhone"                mac-address=00:00:00:00:00:00 server=DHCP_VLAN17
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBFZ3g0cUp0WGZkbkhscVdNODFWY29QdHp0ZFFvUnJnbTg2OGE5UHpOWWxRCk5jTUpFUml6L1U4K3BmVUVRZkcyaFJJc043VVZ4amxpV0VKUlMvTG9KWmcKLT4gWDI1NTE5IDRpZUl2SVN4cWltM3pQM09hSFZjaHRCU2w1cVhyWUNtWldMZDFlbkI5bVEKNW1zNHdMenRwTWY3bE1xN0N4cENHWEFERWgxU3EwRzFOWDNxemVVNCtPVQotPiBeVSNsLWdyZWFzZSB4MF1mfVNLSyB6CkJqemI1UXk4WGQ1dkVxaTJ3c2tqZzBjMi9YMzA1WnI3U0lkeENOWXhlNXhJZnB6azd3U1ZxQQotLS0ga2hXZWZUcWZ1ZEtNRUxXaTNMUjU3REtyYWxFU1V4OHhkQWVXaHU4enZPQQrHxkeidMU-OTvsq5icyul7lDrc3YTMzNYw2agLcTv57XSMzeqH_furf8NFTdh1z72nS6TvW73s1rGeQYnPRMak4lqFOr42wCSziGedbETc9u8eOQj5MGp6bq9r3m5K271Vdz8B-SODJQjbakfpoTnI4Qu4ExNETLNYzHyyQrhLws4LDtSonjP4cfzPIsQl
REDACTED add address=192.168.17.7 comment="Razzy (Core Ethernet)"      mac-address=00:00:00:00:00:00 server=DHCP_VLAN17
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSA1Wm5wKys3V1hMZ1lUbkkyOWQ0a0Q5VTEvWTR2NHRxVlJ5TU8rNDVWZlc0ClRJM3FhT2FlM1p3MXB5RTZyKzFuSzNKdW5rVzU3UjVBUm5iMWJVNTE5djAKLT4gWDI1NTE5IEJHYXJiVkY0dWYxcEVJaUFvbnIzU3pNOXo3MEt4RXVmSHhaR29mdzMzQUUKeWc4NDY2V3VkRjJtT0g3cWRjV0lrUjlsRmZENFM1eVR6c25QRmVlODZwOAotPiBfTkEtZ3JlYXNlICEqeUF6JUAgXXRJT3Q9YmgKbU5KM2ozYWVYMmJzUDdKQXJQTHp0UkExY2FSYjRBelAzNUt6Q1RrWUFoNHJBb3lydkdBRm5DTG56OEFQeWxSYwp6Zk00LzFIaUJocU51Z1VHNnlTQ1YxMFEzN09iV0JMYTlueG1EK1VneUt0MnNzaW5lVlBICi0tLSA3Y1QrWVNNNzZSdDZlWC8rVVpGb0NzYzliUDl1UVNqUEJ3OHVzcWwremlBCqaAIwomWLz6Dc3936C_I-uO25r9A--0YoKteOLz80VhBeCcaN5yr8kSk2upWin5VL_9ccAjB5QSXsgX16N1n_TLxBCOjhDXh3IjmJna_qzVvDmiqgAiVfCYhThxcv90XOZXaSoh3NSY71FkkwkI3m3GEMgEUP4bAT9dMpiDP-sXAOKgnDk3Etl0b8FMzuk
REDACTED add address=192.168.17.8 comment="Razzy (Ethernet)"           mac-address=00:00:00:00:00:00 server=DHCP_VLAN17
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBndGo2WG9obGZtL21JZlo2by9zUmRHaTZmeFpBbE1qYklSL25mTWtpb1RJClBnN2s5K2ZDNUM3YXljcVZsQzE5b2FWNDdXTDBkUjVjUm4rYWVLbkswemMKLT4gWDI1NTE5IE8xYU5DMkpkN1g4dUdUdWx6TUttdFBiVVRaT2RKdEo0d3M1aFRucGlEanMKN050c2xUNk84V3VrUi9kTXBSY0N6aDdqaWEweC95QkpSNWVuckkyT2NaMAotPiBFKC1ncmVhc2UgfmQKbUtpaWJadm5CeHZNRDhvUUUyRGQzdwotLS0gVGwxVjNDWU1RZnJOSHdZajN2QTN6enNMZ2xNRlpla2JLdENzKzFLdW40awrGzsHWnc41NyybfSrlFTztBDL7Y9JK93vMaV03wYvUJpAw91Gu-bLcoJ17LaFTSSTBYA5HVVZypbO-NT5TfTmOh7CKLMtDztROvX0Bk3LPH51FgqS-ibuo1jmHf1K5sp3SXdCU7_vRsQmDxhaOVqnP8Is_Ye_8yyY2UcC9ujJjAIr5Ce9i9GEYaZxlPtLm
REDACTED add address=192.168.17.9 comment="Razzy (WiFi)"               mac-address=00:00:00:00:00:00 server=DHCP_VLAN17
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSByVVNOakE1MHRTSlhib1k1Z2R2N2xsNVZFb01qWHBPVFZTUmd0cnZFb2s0CkZzaXNyeHVpWVNVcTQ4cm05MG84V0ZpUlRYK29ORDAwcHdVVjY1YU5nS2cKLT4gWDI1NTE5IHVtT0RybERIV0NJSFR2RUp1SXVQZUlaSDltekFmVjJPZGFaNHp0WWtkMXcKN1ZRYUt2THV3WUJhdnhRd3ZMMXRHMnR5cDhCaUJyWWZrZCtOOUptaUgwYwotPiBJLWdyZWFzZQp1ZlZuUEFCR0pRCi0tLSBnT0VHQjNrSENXNVAzVnZUbmMzU3pqRk9BOUplbDYvdUd5dXV0dWlQWmlnCgsBIjHuRxKVXnrGZKJxVliUR2musc5XVB7cTcOtf8QCIWWRpirnkqCUOAepRke3HDdYX5Iori-y6dL728xgYgK7R-1EQJYGZtJhLudeMe8IfnoS53yj-xbElYV-EUrhQePV_moz-aLZxvw-T5A_0ClsfeGpkW842ijtJTfe5b1vgzXN3BTsAB-TtZ1sIhg
REDACTED add address=192.168.17.10 comment="Tabby1"                    mac-address=00:00:00:00:00:00 server=DHCP_VLAN17

## Internal - Smart Home ##
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBOQzVqV3pOOGhKRTA3N1RYRWliTDkwd3lxK2ZXOThoRW00aExqZHFGZVMwCmE3T01HQ2Q1R01oblRpTVJRU0dzRTlvK3ZGUXBBOGxlenRXNy83dUYyTVEKLT4gWDI1NTE5IG1QR2VLL1Z1clhqZlZsNHFGY202bjFXb2REbDluN21CUzlqQktaRDVPM2sKZm1xRlFPeDFINkY0NnNzejMvOXJ2M0Z0WTA5c24wRXcvWWhYOFcrNVpKZwotPiBwdy1ncmVhc2UgeDZvIHxJYSBeJk19KApkZwotLS0gSk54ZEMwZjZFZFJiVW1Ddkh2U0pYUm9DUW5RMGxKYmFaZktTbUIwWGZ5Zwo1wpl67HA1G2lFDz4DxOBVg8GOf7GRgXQZGH1SVB6TcThRgba0fPoGRcnfsNIObL4PTn286M1_UiK7zNgvrcwIvtyg18bZ4lZmwbmv3xw6MTlMcCux3zQG93PjJjDW90d4kOBCAebqCgjsl5Gnk5h1-iM1265507DjrKJUAM-XxuDyo64om9bQ_4HCyehPxOAVyk9hNg
REDACTED add address=192.168.19.3  comment="ADT-Router"                       mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSAzaFdvU1dUZUpHMmJ6TGprb2RJNFBld1UxT3N6Y0hpQkQvalFZUVJuUkUwCnBoSkFySTlYdVVrQ3ZMcEljZTRZYWZVd3BUNll6Q2J3SmU5MHpnZXNZR3MKLT4gWDI1NTE5IHNsNCtrMzlKd1ZidDJtU09UQjUvaUZUS2FvQ25KVGlqVE9CdVI2eFEwbnMKNjQralZTRWZNSzJGeklyK2hjZkVsSlI2RldmakZoVlg5VS83dXJlL0VJUQotPiBWNDRKbipwey1ncmVhc2UKa2lCbHdkODRyS2RuT2dOUWcrQXlmUVkxb1RHQm9IL2xheXhJTG5YZkFVNFVyOEU1Y0IyM0hFb2ZIalJqOTZ2bQpkQlBNYVdPc05ZMEwyT1BOMnh3UmFnaFpWNjJPNlhBCi0tLSAvUDZZUDRYVDRRemJQdGlFaDRDTUpkellUOHJkc3JHdlFsWTJ6amxYSHh3Cot3bHjhNhFQRBFodRakFr5n45N1Yr4a9cIpZEIaYKiYFy5-9iNoWsluzsU6jFNSZm6UbwPAO7O2uO_cLM1vo3e3mJFjBM7rt9UilLs8bPklrfuqALQduz5L2BwDXa7E2_TfZTzmkv7tku4MV4ZQD__wL3sLdnizcoS75kzTA43EO_Grjx5pZGsDP1OHUMxRIYvZfIhR
REDACTED add address=192.168.19.4  comment="Alexa1"                           mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBSQ0lXME5BZ1E0a0JpdVZTQ0JiY0pOWFRYN2tFemQxemVhaTFBVlF0TG5jCjBTaUhyQ1N3UXhENU5QQ3liVkgxZzRZd0NzbEsxOGs5K0JrUWRnK1dxd2MKLT4gWDI1NTE5IGNQWFpXQXRZdVZXVE5iZi9KTzlhWmV3WmJhc1liVU92eGlQVitaVW1DVEkKa1M5eTdTTm1MNlR6L1g0WERUVjRhUEI3NlFVdU1uS1RZdVJRSGt1K3VPbwotPiBPOC55O0ZLRy1ncmVhc2UKc2JEWAotLS0gNmxCZnlpNDdJUDQ4bW9GdEJZTG53Z2I0UHk4UUpqR24zMEZYTHdQNFRpWQpN8NknbNbS3kftzQH1xXmtVhKIJs44xpCgUtf_VZ5-pUovB5-mBGuloxOudKBPbYzxqxd4z3NELVEJWpxg9CQTyKNn9gCZSACDzsx7G3z12S55ygDV-0ebyjVQ9BFpH0gvLTrARwoIbRbUKDG-_Fi3tzeIr-Rapd83uW43Yjh_ZFSbW1mf5tRwtrCYIt-238O4iLPSiw
REDACTED add address=192.168.19.5  comment="Alexa2"                           mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSA3V1VpMHpweWg2RkJOLy9pc0ZSYjlQTzFLVDkvUnRYSWtobHFIbktURmhjCm4ya3BscDhSUythdUwvN2loY1oxRldLZytEZnVBQkptZ1RUL2VUWDk1S0UKLT4gWDI1NTE5IGF4bW1OODNBOE91a0hlZlVKSXFMcjlLaFd0cTdZenVZL2hVejUvNjE5VXcKSnZQMEpkZ25TWnB3dnRGZ2hOUFpQNUs1S0RkTlZycStCUktFLzIzaDFoYwotPiBOVSRPfS1ncmVhc2UgNSV3ICwKWFdxUTZUZW9KTHNFM1RUVjBvS0RSTEV6eUlhSnlUdDk2bkFKeVE2emlwVG5xenphYi9NOCtHeWFoQnpKb1p5Kwo3M0lKCi0tLSBncm9OakluZjVnMjl1OXdUeWFicWhpQWhNYlB1dlVnY3dqdVNScE9ObUFnCiXBXOI_Y3EKOV-SGkkJWAjFLGLI0mN9lWSrO2WU7M0DQcSVYh8d87I-sskoukK-zJHdNXlEDcfesCv0VvqocMLseUgaCfSjelhhQ7J4O2S5VmWto3sf9V9xfHYTXohuP1mctuGflCseLtFKcccblJ_sJYxWv5wzFaLK_LWI7mUftHZ_2Dq5t0RrkbI24pSCVPWSrN3c
REDACTED add address=192.168.19.6  comment="Baby-Cam1"                        mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSB1Qzh1cFFvd1dYQzNuaFdGcXZjSi96WHdaenlzejFZbXVCNVNreENiQVN3CkE3TWo0d2tFMDBaWFZGWmdSbzk4aEJZTVBCQjNBM0QrSWRYV0R4N1MvNWMKLT4gWDI1NTE5IDV3SGxsUy9WNHVENUE4SGZWMm4rQUR6d2Q0WUdoSTR1TWxSRjM1ZnBvUkUKQzF3K2NIT0gxK0o4aVRZa3JnNmVIV29SVGhRR1o0d1JlQit1enpHWDc4cwotPiBTWW5wLWdyZWFzZSBlRVVRLVZRXQpjcVF3WkhNZUZ1TVJWdTFTUGtwSndHS2EvR3VvNVZuYnI1a0IKLS0tIFZkVXY0NlBCNzFUZVA0dGJZaWZYbEROL3ZTWUVmbHZNUjA2UkZCdmpSRE0KXGg0sB9tjYcm_3ePaa0jxB_WhZQ8rKV_0FpNn0_lIEXodJ2qWeBUjLVQjibTBhNgq8zUgAELbNqiV4FiqYM1S5EsS2CQxi9qetLH9rR-aHLnAFZa3mpGSV8jZ8Yw-K80S29cBq4D5juOXgDPgnZUCsTEBMa3gEa2mxTu0OJsHCKC3Y7n5HKfL6nVExRjyWqXexKRL24
REDACTED add address=192.168.19.7  comment="Kasa-Bulb1 (Fan-FL)"              mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBWN3JZcVNxWW1sdEZnd0FKMThqNjFvTVY3ZkZDaitISjFOcXNyTFFJWlVjClptblluUThSbG5ER3BTY2RrY1VUSW1zL1I0ZitSdm5xT3A0bCtxRVJuMkkKLT4gWDI1NTE5IDdRdG13T1M4QVNwQStncDlHazlZQm9GdjNVeXBPdVh1VXFDWUpFaW1VeEUKVVh2OThDQjRCV1NZRDNkQkt6L0ZoTTlqenFXWGVuNlRaK1d3MDFpWWRoWQotPiBgRmgtZ3JlYXNlIGY3QFBYTSB9JGc9ZUBdMiA6MQpmUitSUHRHdkwvQ1FmR2FRCi0tLSA5UTdJbi9aNE4yc21Mb3hsUHVSMkw2VEJvczVuOVpDQUZldU1rRjRDaXhBCmzQhjYBuIf6Eo81TnOXkaJQyKA21YhbXqe6SWJcuFCGlcNj99LfTEykosALHUKyGJGAESljgn1YdN-7OtQGP-vDsrwKhMFqS7qD76GA8E4EF7GaFiyL51eOiGy0PPgPwRteL6qZCwD0l406YBTa8uU0OkwGjvWfd0bjKvFSNmeJ65-aAWrU15Lm0fVdimz16c5Cziot
REDACTED add address=192.168.19.8  comment="Kasa-Bulb2 (Fan-FR)"              mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBBeFpZWlNqRklXRU1aZS9NWjBrVmVoRXcyS01FTnpKRlVZMEJhajBGeVZJCnM5L0xvb3BweTlSNGpKR3o4OE9EUFpWZEVKOUR5UUtBWUt0SUF3Ni9oVE0KLT4gWDI1NTE5IHNKWmtyWU1aZlQrdUluMTE4cnF1MkhvdUZxNGNYM0t6TXVnYzhONGZEUVUKRXNWLzhPTHlhYUFXeEJNWVNjbmg5OUZlb25US0c0MTBtdS8rZzlNUEt4TQotPiAuX1JqMi1ncmVhc2UgekUscWZuX14ga3onezZjOQoxZ0dFUjZFSU1oald3clJkWWlORTYvUDgwOUp3Q1BWYVFpTlk4VXlpWEJZNgotLS0gRCtRSmJnQmN4ek53SGNqN2M0OXdZME9Nc0lzd0J6djBkeUFJVnVPVFhtVQooko_PynnDXh_moghSV4lF7P-mYX6uIlACFhKffTfZJ9bq7iYIMAwQGcWi6cBFxAkUcqKVBsj4QdCTL0MS2uRnlYFmXcHTifnUAeDp2Lo30ORu-aLUl5v1CmTkfDKsUga6VkYZ-ADmHyaYMhnguxWduRlzDzwf1X2Tk1XIiyIM3x2r6TF_3PSr-FCbpIN9CloEeze9eA
REDACTED add address=192.168.19.9  comment="Kasa-Bulb3 (Fan-RL)"              mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSArbVJ2Z3ZxRnB6NnVwcTM4djhBL1RyblhmTmRSSXlKQ0tBUE1OakR5Nnp3CkZ6VGNEKy9NTFQ5ODZEeGZaaDc1QXp6SWZ5Tkc3VHZOcDllQjZXS1FPcTQKLT4gWDI1NTE5IEsxQ0ZGellxOGtzMllrYkk5K1Q2WG83aGlpbXF4YXozWE54aU1jbVNlV1UKcGJVZGE4MEpWTENBOWVJZHJKUzV0SHJMYWpIQStmWHVHbzFidU1BZVlzRQotPiBVYkh2LWdyZWFzZSAkXmhZeSBULCVVCndYekhDaWZHV2VuUmR4cXBXOHZ0dDVvak1qL3lmVXhJY1UwL2lvdytnNEp6cnRQZ3RCbTQwb1dYUXUrTlJpV2kKQmpRMGV2MVJXTzAwYzNST2JpWGR6bkRvbFROdzVPL0hFVFlTVGtRY0k4d0JaYlZpUkxYbQotLS0gWmlJVlZVSENTQlIrTjU1RGlPaGtlVktDVE9BQk0rMXFybEYwWVU3WXNGVQo-d_v0OAh5dOSEUsNUohROHoH9KMBSaaKHTkid-s5PzeEkQIjlqFjiNSnNNrdSG3N5JBFyhGximPBJlc8kkEOpjnRHzDsWwDwdU3AFMfSFqqS5XcUxgjo_bg1rDaQ_Zb1BRK95XE9RWrz6gdy4Oal1jFq60AJGSiMuihzcGv6DvNIuh-t8vXQY3eGFGYcNCut-IFoOqQ
REDACTED add address=192.168.19.10 comment="Kasa-Bulb4 (Fan-RR)"              mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBXZFFEdkV5Ym50NFd3MmY1MEdqRU51SmE0S1VQZU1PQzBGS1d3VUFWVkRFCmZ3dDVTUEtUeDJxTjQwV0k3UjAybXNDS1ZyWVFtUURDVmcydGkvYklqQU0KLT4gWDI1NTE5IG4xb0pGMHJQcmNuY0JNVXQraVZMVXRIbkRZL2VtSWJ6SmwvQzNxTGQ4Z28KV1R2WHR3ZG5Jbmc4dWJVYUhXQmFUN1lTZ3hkb2tlSmZENDJyYlB2NnpEQQotPiA2LWdyZWFzZSB0L2FOPDBBIHBXZi85WQp1eTNwSzRRZWxXQkQ4eVVtRDZRSWNUMVM1TnlaZ1JLSitxdUhTc2drdFVsa1VxWmtVbC83YVU4akMzTXR5RjhiCnNERHhYQncrcEhhbXRaTUIxa3BRalRnbGdkK2FXQlc4MnpyVVU5aUsxYTNvRVEKLS0tIGFCRjY0bDhHUU5MbUQxdWdzWWxhY1FQbUJrZThvYkFRdGR3bU5DVEZiZncK7b0IA82o1rUvCQyTwDUGWfIdt67Ltn2UOVipSPnYe8WVkv6rVwtOjXXDKwhl6nEYMED89Og_JnViz-AotbzrrL4uDFPl5MQcfnNej1Wh7iAGrQZ3qdtS1xfypluXR3YXtMCaE5YR3kIJcJ7OB6kEJdlG1eVkK5yZ9O1Zk6B1LyNJx4Cg_-F3h68DsTQSO0vn0yvHfIo
REDACTED add address=192.168.19.11 comment="Kasa-Bulb5 (Lamp)"                mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBWY2dGR3h5dHI1bmFUVk1QOU5jWC9mZDEzRXNRTCtEQ1hoVndpTFgwVHp3CjJNR04yTTNNVDN5RXBFbUtHVjIzSWJ6Q3JicG14akE2eGtIYlAyeXpUVEkKLT4gWDI1NTE5IEh5Uy9VaExoTmtUK1lDYWRmMXlENHV5bUt3ZHQ5bnVjaGczdENTd05PVGcKbGppVjF5cXBodEYwOUNyajEzNlFKYUhLWWNZRHQwMlArdTZkaytvMHpyRQotPiBFbHwqITY3LWdyZWFzZQpDa1NuQmcKLS0tIGtHU1dsckNscW85SXFiZnlnL2VLVzY1ZFAyRzVBSmxDNjFCOFhDbXJZdWcKJPMBhL6yTZsa3XBQPv4--zayM8fMBRM1sz97XC_0dYnWUtjhZr7Pckar1JPBp9s0sH93YQD_fEKsjpqax191kzDfUKw6HJgBtE8hsZYQOwGcP_gxzGGDTb-MZ68vaDT_SHMKxKfurrjL6_SaDbxDFTFMRdBqXC4z_91v4LwVix24lh6L2Cj1vjXIJXBmSXYchZn3bwE
REDACTED add address=192.168.19.12 comment="Kasa-Bulb6 (B-Nook-1)"            mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSB4MUM3dGd3cExmcW1RTnVEeDFHOTdHeVVnYXZrNVpNZUxCb2cvSW9ySXg0CmJzeGVEejUyai9PMk9XZlRtbVl6YW1NYkpxRzZQYTZqRzdnQWw5VXkySUEKLT4gWDI1NTE5IHdocVpkTUpNY0NYQXZ0bWJWY1VYemUreDRwY3h6UmlxeFNmeklESnk0aGcKdzVQbVJWOWlPb1dMNTRBM2tPcFcwMTJVZXdLbDNlMWJJWm9LamlLTVUyRQotPiBrNlp4Sl0tZ3JlYXNlIEkKaGliU3NoQUhsRnNUeUhwTzh0cTFJWDJEV1hMeklobG9xZHgvMUE3dDFnenNpYzZpMGpabTFBaDBxUGIxWFFiNApCek5yYnM0eFN1ZnMxT0w2Zk5wVzJNUzNNQXo4UW1VVHdkN2d4VG82dSt0NXdrY0hnMzNabncKLS0tIDFieTlKVmd1RjJaZW1QQ2NxM2pTbjIyUnkxUytMVXJvLy9WRXNhcUZXcEUKd8dI-TPvSMn0Rbuq3o8vpwORmbcTrA7l8tTohDF4f3FLsgdHxnZhDI2UZvdPQVen1HExyYVYmRLRFYaULOlCW95bW5F8lxsvO4Sn-Mecdxlw_Viqi93aSevST-HRJo0UrjfSE_WGhtZeQVdjdxMA7WPdXKBGAEmOMPY9UhapCyIIlOYROdeFU1DmNt6Y_2MCvC5isEQ
REDACTED add address=192.168.19.13 comment="Kasa-Bulb7 (B-Nook-2)"            mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBoUzlHcHZkRjNkRHB1bTZLRXN2NGdBUzNpRlpWQ2FSM1pRbTBBZE5GbjJNCjhRK2xwWnNTVksyY1E4THkwV3dGb2o3VlRjblpSVG5tRWIzOHZ0SHIxL1EKLT4gWDI1NTE5IEppVHFQaGtML2hRenQ0R0QxNEVJK3pjSGdsK1NHSlRGWEZjd1ppVjdRRU0KVlpacjBIYWFFZUJFM2h4bUh6TERZOFJuSjB3QkxGa0hGWHVPb2xOS0xXVQotPiAkZE4tZ3JlYXNlICsgL0cKSXVUNlBDZHpSNjAydlV3RkVkN3k5eU45SitKem9JcTNISGtNZkdkMEZYQmdLOUpTeXZuYzRDajVOZ1h5ZnlaNworQjhWOFBuSXp5YjZjYVVBMFZ3RG1vb05IaGMxQlJLVXZZb1QyUQotLS0gWGZJTDZqSkFraFFkZmZWcmFDS1pzeithTSsydGVqRG9BVFpQVEhGUG1lWQpD7yTig7PpeL5lfZqRDVE_zRn13RYyktbGTmQ2SCozON7P9bJRzZ1lDr72l5F9SG4ND1rSWwi2bgayRNfCYkKu7h9VJx3U84APBeyVWpWBkOuYex_g0vYG-AXvufyJLPY402RrJX3b3_elo_Pk7hESj7e73Q3tmYyhvzlD7Weweduz41K_fhtvHJMJ8vfAypJaxYnr3Q
REDACTED add address=192.168.19.14 comment="Kasa-Bulb8 (B-Nook-3)"            mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSAvWFFZZ3A4bTRCMS9PTlVsMzlEYXRRa0cvOGxzWG0vanc2NW9tcGpuRVJVCitzQWlpSHR2UTZBTjFyUjMyWFgyR09vRWhnZTJaWE1EYzZCMlpaRGtlNUUKLT4gWDI1NTE5IFhwVG5LVGJZTTdvZFI2N2svK0dtZUs5Qndlc3phaTJqMFJoNlUrcU1ERHMKSm1nVkVWVUtIL0VVWEtCdUhvTWhvZXZlYnBjanYvN0R3MFZFZTJPOWdNWQotPiBFXl5EUzA5LWdyZWFzZSBAJ09oMwp5UVZMU3FHa3d2VHV6TDJMY1NaZFUrWDlneGtGSXJoUnE2RWc2dVNlTWJBCi0tLSBGZ0NDcVc0czR3SThQWVpKbWdWZzNGNHJQdFNiNG5keko0L0hLbVA1Q1FBCpcAwWsqGSQqPSmoFOg8ieIJ-1nB_bkMQCGdPA-bVou_pefd8er8FQEryZIc-knK0X-6GSSkkQQA-0ugcZBVrC6AaB-qWMfCdugRb7VCIZv9kXFsERXZeQXLNnm8YRScetN3YFXSZN4kqUnbMwpieL470oLAo1upJJstxbRpB8b6crp8U0ggSbjKDDP8NiUylg-a7d1y
REDACTED add address=192.168.19.15 comment="LED-Strip1 (Bed Lights)"          mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBqKy82RGlqMVpKRDQvWTVQOEZnRDlPR0FvQ05yOS81dGR0aGtUTlkxbG5rCjhYaGhEQ3pFblNpM1paTEJlekVQNGMydVY4YVJaOEdwZmRUbS9jWVhqTGcKLT4gWDI1NTE5IFhncFdxUjVoUlV4WmxUOEVOa1V3aXd4WmxURENQek9rRk1rSDBrVFRzWDgKM0RrVjBzS1RnckwrYVF3dFJrSGpmNDB2RHE2RVY0Z21FRkZpaWVGNDJ5YwotPiAtIllfcS1ncmVhc2UgSGNKICFJJEdXPyBlcSBYCmFac1FuVXF2U3VBcGxXeThScU4vbHZQOFFXd3NsZm5ab3BIckhjbFJwcW0wenF2eUVGa1lZTmVsSFF3OXZYRVcKd0pPaCtVSFIwVmJOM0tNY2dEVlRxN1paL1dHQkdoeU1aN1BvMWxxTDI1ZjUzZStYdEM1bjc4dwotLS0geGZuNVFJR2NGRWJMc2hSbk5UWGdENS9xbkkrWVJEa3FHMjk1Y1h6NGoyTQoEGyQVChpOjaW0BGZJxP5nSdiHB6tQvwPHY8Dk1C2FGvvptvD-ia_KnbTXr2h8TyKshJYhnztwmSVmw2h0IdAvUK2So-mgUHb88n2cE4RgYxeua0jI1iQN5En1sI1wSBUMEWhBD7UC6iIfG2YiUXPL8DpFSVVyVTCgqckEZ6IeOEJ0CviXjjc0KfjYmcg_a0MWp1xWpw
REDACTED add address=192.168.19.16 comment="LED-Strip2 (Dining Room)"         mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBqajBUM2F3MUVvZnM5RnQyeklaWDRKSkNGdDVCalIyV3F5Yk1OUTZaeGljClZ3U1NCcEVVTGpxUFhaVXQxU2hjNk1FeVF6TndGSzJjaFZ3WTV4cys5SUUKLT4gWDI1NTE5IHhoNGFoQ1JQQ1c0T2RESVcvVHRrYm5KNmtlcUZJV2pEUFFHbnViN3FJaUEKZjR5SU9ya3NhVzFsdThPL2xsSzVXZWVmZzFIdkNLWmZteFdWNUtpVVA5WQotPiBzJjBCN0MtZ3JlYXNlCnFGUHZMLzVjN09YNzlwNjJUbkhlZGVBbHNmZEp0VjQwY0lRcjVzbUtoQ0NPc2ZZRnRwcHYxSGR0VHpVYVFtYVYKUkxWaCtWV3JvRDNkRnkwTmdCajN1ckhsRFE5aDdZd2R6NXFhTjRnCi0tLSBueGE3MExqcVNWcnh2M2MrQ3Z2N3BsZVhtb20rM3ZwM3FmWnVCM2Nwa3hNCqsL1syNh40AYiXc_jLrjbu6ElIQn6W490rk7-YZHdTcIb71jlwpYwFXLqz-pLfCs1KDCZD5nfvG8zFfPbF3JPqFYK_JbJpoNxTSxmJgm1CbBmwTzGuuFgBhowZovu4MIEB3r8eagZnDy51a_cXg1c6t7vTl9XSxJemzCeXZ4trFHIyN36G27AYBDiywOqdqb479DsrY
REDACTED add address=192.168.19.17 comment="LED-Strip3 (Living Room)"         mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBWVS9Ca0tzQjUreHJGc25nTWtCL1hTdmM5bGVXU0xrWDVYWGZHRTdDZ0drCldhR1NkQ0RvMnUvLzM2a1dQVktubHRXck5HTG9MbWtsbU51U0s4SklCUHcKLT4gWDI1NTE5IHUxMjN1bmpodUI1SFpQbVNpUFhDSEVUZkZjbEY2dlQ4VDVxZEZMSnc4VDAKUVRBTGZ3bEx0MW1WMmMrai8ya0l5VjRtTklXQnJtcjI0U3Y5d0JWejdRUQotPiA9LWdyZWFzZSBJIG9yTVJPciA7PHxzNiB1eSk5U1QKMmM4VmU2Y1FzUmI2RGZybWIzZTBaZU1KazBCOVRNdkJSbHFKTUNubFZLN0xmQnR0YmpXcWZqc1A5TDM5L3JiNQpWOFREeHV4NlFSVERKamVNOUhmSDFIOTlmdHJTMjVkVEJpZW5uZwotLS0gVElDa0FLc3owZThrUWdnYWpZUTdXOWhIRWd2NFh3ZGJrNTdxSUwrc3NsYwqGjUKV7T2WqtojXhwyescEbNhjgEETRlnbIDpk03-FYBOiEk85YR1mbnduOE2ngu9MVoY5LAYn1YEm_nIEZ4JKOeCOvTZ1c4k77llnuJtz7Td3noatzrZftYZsbpP6RLhV7prlbos9GgSuHi2gdb-qTwLM_Bctrclp2_oCmMDTE9GcKU4gIaKySEgvDOh_JXb2LQQnpA
REDACTED add address=192.168.19.18 comment="LED-Strip4 (Kitchen Hutch)"       mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBVN0FudVJtc2FNRnlmay83TjJXUlFkVDA1ZEtmOUZrVk9HV2FGVDdUUzFzCmdMTzQ4bzhFVU80R3JJa202TFluQjlpYTNUVnEyM2tqMGFLdXlFYXozeVUKLT4gWDI1NTE5IDhzaDZyblhybWdpVnBlWVpqVHhzQnZGMHg4S091WmhkeVdiRy9zK0lxbTgKQnloTHhteUZlTVFFbVpWZFpvVVFVVi9MaXA5RG4wNWJyamJ1Z1BnTmRhawotPiB-LWdyZWFzZSAjTwp1RlQ3TmQxZ0NzQ1RWdGRnVk9UdnIwOVA0a1pwRjNIa2N6aWU2c0NldG9GMVVJY3c4bG9QbFdjOG1UTVlUdllNCkF3RDRpMDZiUjg4UzRtNE8rTFF1YVd0dGgrRW8xVExZcm1tVDgyd0dWakFaeW8zVEs0ZURUL3NlCi0tLSBJTzVORXBiSHlwZDQvc2tDTTR4b3pWUDdSM3h1eHlUTUl1SUhJNHZWZ1VvCtXGU4ln3o0JuC5c8PVfRCgeow65ZcL4D_KyrMx9nOlhyAERNzHpb13dk9z4-8wdlivxNrgaWU66CisLBDOt_xWFvM6F7cP588so4z3xWhGlKjnIzAUc8gEEgCLMnxK9LtHbpGDTzV06KxHcEBkmJfpXgswD8teAggTmg2RhJWC7fdk2TKUIlny02VC8g93J7juntGEV
REDACTED add address=192.168.19.19 comment="Smart-Plug1 (Ender3)"             mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBnVnZTTnhVVFJKaktLSkZJd1E4NWNra3FqWGVQMm5VaWwvT0RIY2NudjNJClpoUW8yWmVtWWFrNlFEU0ZOVFNTeDNTL2RyOGRKQURabjRSYnpBM2kvVGsKLT4gWDI1NTE5IHc4T2xpOWZDaERMTlBYbERkRkhCVmpRY2ppam4rTHNxRXJUTFlCTDVXbEkKSFk1LzFHc2tIaG5qSUp3bHl6TWs0dU9peW1RTERGSWRQZmdYVU5nL0FKSQotPiAmaXEtZ3JlYXNlIHhYdy9EICU_Cm5qbXNZMmtNV3VzWndOa0VKMEpteEdCK3Bycm5nNm9PZW12NAotLS0gTnNpeGtqRGtsaXR3LzZiQ2xxUW1UNGk3QTJ4VUxVNlMrSHFhODZEbFBiYwo0uYo8dz8-FLv2lhYmqy8DGJBEuj3DmwNpPPC-RfLgMItkalq_XVZxnTfl2iw291Og2FSsSP4V5xnOHl13GXCEEaq_TIVUNkSDofHqJ06dMgL0VIQUA1YQy_UkzBs7bK6zqhzDmTSUJbtmVPBA5FtUnPls3sYmr71HQyRWVAyfUeNG1_DBTpfp4gigV5k69uDhLdgxuQ
REDACTED add address=192.168.19.20 comment="Smart-Plug2 (Anycubic)"           mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSA5alJoKzNiQW5idU5IR0xVb0lGY0JQNVpNUjdlMW1BZlVVbTNpaGtzSzJZCjdhdDZzaEMwTmQ5aGtKN2RzMElUb0tBc2UycExyOTlzQVBnVXJWYU05c28KLT4gWDI1NTE5ICtZd1IwV2FyL3JGM1A4MFpLTlhBbkIyVy9VNzhtQWZnOEpzdGpTMGcxejQKNWt1RHZzcGNKWUk1bjhDMlFNQTVoR2hhWVhqczVBODR1ZHlKbjJ1S1l2bwotPiBua09iOXBrfi1ncmVhc2UKRk55WmQva1lXUQotLS0gNlp2NDJNcnlGbVRPYjhISkVXQjI4ck9ZeFpNTjF3R21SS1VXZFdYcitvNApj_Yv_E3KJu-fzLGcXj8UXJMW5WYGvk5RhWiPJ-_g62w7fqQmusxZQqiNBbwZfdUpxVfqTT-LIxtSHFxrW7M5HzXIswcThObR2Vxb8FJUlqt7FQEQx0a_3lPBOsF-E-fk2MCZJPKCz_ThhcVGqVFSb4exMFpuHztLyFUZSqJwEqyqswbCJDtKc7dmZaZP19b5zMLIL-Q
REDACTED add address=192.168.19.21 comment="Smart-Plug3 (Clock)"              mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBreStxalpmMXZXSTUyblkvYU1kQndBN3c5bmVRZFlYSFVPOWxwcTduTGg0ClJLMURRazB1elpRTjZlQUVuQlJSV1ByZkdyODNKUmVULzV4Z3pVWGU5bGcKLT4gWDI1NTE5IHEzN05yTFB3QXFFcUtEbjJib3lmVGdNSnBEOFVsVDUraVdNbWEzT3kyUnMKZXRSTEZ4NWkzS3dKRmxoNjgwUlYrSmMxRGJzYktvOXEzYVBhZDlxT2tvSQotPiB-JyEtZ3JlYXNlCkJad1ROcWd5RGM0b2lZR1RwWVQ5b3ovWVh1dklSTnBhT01zOGxudndLdks2cm1ic0xCVlhocTdiSlhaWUVuSmMKNG1qREFZdWZVMUVKRjFLRVhoSWxtNXBJbWk0RTlEK0d2S1VlQ0t6QgotLS0gZ0gxT0lYMmY0MEZYWjNrYUdMSUowTnNSQjBsQXJNdDVpdFhaMURmUVhmOAoIljUdUqmTeHeXMs3YQxsAtTzIvaaEtwYQiPnFw1aIWk54zfrF56s1XJTunQmDIvAVahx3Jk2tkJjv3LIxRPm3OB-IcAbj67zFCDeRf16iwXPugZWNVkVvISMrOGRcye1WQOJEmLLdRI9lyzPO0A9-fH5boVMY17-3Q5hN9KKvupY9YoxZ8Gk6Er8QkMkLzqy0-BsTAQ
REDACTED add address=192.168.19.22 comment="Smart-Plug4 (China Cabinet)"      mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBSa1FaWFllci93V2lBZ3puNE5zR1BCMzF2OGVEUkhLdGpwdlZLZXhDRVZ3CllSV1djNHRnOExFaTdaWFR2YURxUVNUZ05ieDhzRWw1VWMzV3JMKzBrVjgKLT4gWDI1NTE5IHpVT3VjSTd6M3ZSeW9LMjBMdUhNZTBaYXJNOVI2MVA5alExbTRiWTNjbTgKd1R0ZktHTVl5ODhrUzI5K2lVdU5iVFJwOExvZ1FnbVhJbkRiSVN4RENyUQotPiBma3ktZ3JlYXNlICt6QSUgMW9SUWokOzwgNF5ZYSBENUkKbWt0OW1xSFpSb3BHRVdjSS9YdlJrR2FOOTNuUDVDNVFEZERHODFWNWVtVFZrMGtaMGdHbFRtaDJlWk1BbjF5SQpsczlKZWsrYVdnZU1BUUY0bUlUd2dSRXI1MFBaTk5ZeStpMGVvT3R1Tm92MlRyYnZJbm83YVlFU2VUL09UcStFCmhUczMKLS0tIFc1RGhXM1Z4TTJjR2d2TCswTndHRkxqNWpXbFBVUGdONzUrZHUvSmEvN2sKN4sXEMT4tlwAdlKDLHDroar0sietsmoMj0c4dFpQ_8uk4KaC34wiYl4pbUH8DVrwM5fxlJQtKoEe6-fDXy62aPZfhv3O-kQE5W1wLuw1eXSr7GadPD_UC74NiWMK17106wl3GLZDgn0XfgJl-nQQ1-LPsw1pn_0ssTCPB7YD4_5peNEISzTwJBFNSD1TXQHiFf8t5bo
REDACTED add address=192.168.19.23 comment="Smart-Plug5 (Bedroom Lights)"     mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBmWWF3UDdIZnBsRm94ZlNpTjg3MFRmQmMySEtzUEpJUU5WSGhNMkdmd21JCmZRZWtpWjhFOHJPYnVWRHZFazVadldFR3ZpcjUxQlNuakNKUU1ROVRCZEUKLT4gWDI1NTE5IHV4RTNrRkxiVVpjbGVKcFI3Rzh1WDU1TE5iaUlyQUZ5THM5V2Fwb25iMEUKTFhUU3FYVExYcjlTUHB1RnNKa2IzbHEySmJ5d2Z5am8yWlJuZU1Rci81TQotPiBBI2UqLWdyZWFzZSBzR3tbTWlaOSAoXGtmZyBWI2YgN18KK1kvRTh6QzJLS3ZjMkVyYU5wSHlUaWZJMnJ3VEVlVkdrMWNvQTIrd2ZUM1o3Qk0zb0pRRDF5YWZ2VkNyMWp6SQo1eUJmCi0tLSBraHlYcmdKQXZzb1JES2FFTWhyTFZ5YjhMQnNIcVpjNllNSEt2NDNlRlVnCjBPM54ZUgb6PLXytNs-PuTeDJeViDhQkh6kkBqltseio5K0UrTFruKr1rTZSgLM-nfjk-pr0DodmapAXQHADsrceuIyJEk78N-RjqbXAbF88Egn6X-B3bxzfO06PerUyqzdPXnVn3VrUd-ItBp-vwbxVndE3s9gNfsGE7uqEYQYBAXVECE2xGtJdpJGU2s25xe_vJ38
REDACTED add address=192.168.19.24 comment="Smart-Plug6 (Office Lights)"      mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBLYVFQVVgvc1hFQmtTeVBUYzRBNFhjeUh2djhYRWIvbDZHQjNOM1pyeWp3CmFNeXJySGNuUThPYWI2QzkxMHE1TlA3T2ttZ2xuRFQ3cyt3Mm1Ld3BOeVEKLT4gWDI1NTE5IHN0L0hMZ2owK1RIREx2V3BVOGNFRDJJVXB5a09ybFB2c2dENG1PNzl2aUEKQ3ArR3I0cTZPOWp1czYxNUc1R0NhZC9wckwzbmtGTW9kYmlrQ0xmYlhPZwotPiBPb2RzRmU9LWdyZWFzZSBrIFB6Xz5pMiAwQGdnbzRYCkFrRktVeWxpTnBsVTNaYVBXMmZob0JEK2RSOAotLS0gVUk3OUY5cTRmVmVsSTZEZTdvMmwvcEFwS1MzUWk0ZFdiWGN6TXBjYndqYwrrd2K5nZ7vJ5X873iwfQc8_WV6KtFetdqW0JYl5qXHPn4VY5yygpor7hPgT_ziZD-UPqZmY2O0xyVYM1YgUNOTPN5iuyhbTZyVFnSdGOes3ziwFMRMAyyrT2-8aLyRkn6JbV1lQDAqcY7S3tg3-FBX_Za_rlCocxC8_o6lVe3GlmmneBbgjkYWJZuysD1vwzWOmEN4VQ
REDACTED add address=192.168.19.25 comment="Smart-Plug7 (Dining Room Lights)" mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBoS0U4SjRoWFdTdys5N3RFTXowZis5VGxzanZGd0ZYVVZ3N1U0aDZoQVFFCjhYWXhuRWV3cFNjVlpUNmpnZ0ZYVjQvTTc4VFRFcjlvQlNNWXExazYwL3cKLT4gWDI1NTE5IGcrcHEyMkR4NnhTSjZwRGxTN3BHQ2h6Zm9BNVpiK2NTcVMwMVQyeFIwSGsKejhDR1IxcTR0MW5zWTZaL2hJekNSVFZQWGduRGJTQWZvZTl3MTNUc2ZFWQotPiB8V0MuIlsrLWdyZWFzZSBTaCFaWCYKbExUdUNtS0h5NEhMb0JmancyT0JoZ1JFRmZMY2J0YVN2YkpCanJTbVo5UjJuNnlReFB4MTVrTHRMKy9SS2ppSwpOMXZqMEJvCi0tLSBLNm5hUGhLTmM4RU5WdEhLbEdkMHZhekxPR1c2UnlCUysxTWhRQ1RSUXk0Cnn_bRPPaACrU5aEwUAY09zbex78QaWJrn17sdk1GYcMRXfNtPQ23eD2vr5ud7XVn2nRUxMQRhipmcPBh4hTmaGK2cnw46vi7SmB2KB_3j-249TN5KugbbKACbs9lVI7CiyFPj9lI2QWdiNvkEU1YhQ5VlfvoZw5XqKcjICS8SFvzeIxkDQfA7vy8-ILAzrrIE72NKnP
REDACTED add address=192.168.19.26 comment="Smart-Plug8 (Living Room Lights)" mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBtd3I5Tmd6TVpaOXlUSUsvcXFkcVRjRHcyVm45b3Nkc0c0SlhmajRSQ2xJCmxJU2VuZThQaEErTzRwNmpLSmdobXpXVFB0aTIyWi9WS205V1dlQnorZ3MKLT4gWDI1NTE5IEtmNEZCTWRYeFdseXVqRXVXNVE1Y2FPc1BGSEtMOXJxV1d6ZFVrSUNTU3MKRVg3T2VJT3p4aEdTRTFpakprcUFpczRrVHg0c09TWm1BU2FWMVZOckEvRQotPiA1dykrQVctZ3JlYXNlIClrVXtYICpeWDMvIFB0MSBeSUdzCllTcEJKY0N6VllHVGZ6NHRsZ1NYUTNmUTBKMmRwcFNQRUdJZk9UZlRzUUk0UW9rZjhDdUUwZFRzY2c4RStXcwotLS0gOGFMWGdrU3V4QWhaS0RnNWpWM2U2cHBSR2ZWQ1BQY3NsenNQWXRCZEdwVQostU1ztg47kyEEaGXzX_gBAeOCuZVJ-rHWMP321T4H7I_lvTjWsQCyhu2U5SWtI9-v9VSWlpcXxoDP4vfS7OD41AAracfF2R9z-DxQ5ZPZ8MfoZAIbLJRtBMZliNCcGmz4vP3TVLzdZeIs2sKyJLNJvgDLYV3NqDhnW2PB3G1KNsk2GxG-7o7pUV7QeQe46ylUrxFnLw
REDACTED add address=192.168.19.27 comment="Smart-Plug9 (Lighthouse 1)"       mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBvUWhrZ0M4YldpTmJjT09NU1RaTmVvL1hoY2JYRmJEK2JsR1F5bHFGVDFJCmZzSVJ0bU1INndOTWtlU3JRek1jMEVGcEJMRVRRNDFyNWRFakwxckVxV00KLT4gWDI1NTE5IGRmQ2RxLzJPYkYyTGx4QVBJZlF4THQ4aHMzUEVOaXQzdmhqRm9XTGx1eEkKTzVSck5zTEQyRzFDaTdHNHY3dTVtblplMWkySkI2OGI0anhRSGl2NmFDNAotPiBWKS1ncmVhc2UKZEVFN1VOVm5uNFZuR3loQkpST0kzZkRnQkxkc2tXcwotLS0gWUJlQTNHMDErbmlocDNmZU1OalpuNjRQeHluYU1uTm13emErcnZPaEdvcwq83TuDFt5itLfgY_sic9z-pf0ie1SuqKU1Hnlu0OZgqKDnVQK4cF_Od-5ntW8yxgrrl11gRU1S3q_FavJZnNp3mNqqYhbZmrkAt45ijnQD1bO8BavOSa73GJ8Q1Vg_aO5vv9yNjfx1WHIKQQMxJp3HLUhLyccx13YYKnYSAvzVEzjy-MEQ8LmdS_qTvaZ153TVB5q6Cw
REDACTED add address=192.168.19.28 comment="Smart-Plug10 (Lighthouse 2)"      mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBsWkxUbVBEU3FmcVJPc3pabjBxQUdhL084OFRDK3kzYnkra2NkNXFZNDBRCkFJUnhZdWcwbUJKcDBoaWxwZ1lKcjV4UkFXWnZ4aVQ4RndvSUVpdml4aUUKLT4gWDI1NTE5IGtlNUZNdkpPTzRodXlEa21Wc05DdCtjSnNtK3VRWncxZGpwSXBJT1NwekkKeStCWkE3SFFMRmNSa1JxN2tYWTMzaFpPSm5ScTI4c3huSEwzeWhrRVgzUQotPiBPbWJSLWdyZWFzZSAldXheIE8gWWRICkhLWXpOTElIYW9WQ3h1dER0V05pVWVmODRZVUNYUnA3dEs1ai9VTHF3S1BWQjBhdTIyRHhNdUxPK0plc0xnbjkKeGtqNGlqTVJ1ZHd1M3VreHBmeHIKLS0tIGcwOHZPMHVCRm9icmlBSjczQmFBekRZUFFTNUVpNE1NMGc3N09SVjBrWEUKd1AMKFZHpQyYxzUvY7qLjWum9Zas58qOHC3jDtkikjKB6qo9-Z8vA87NuY1Yf8tntVgUuatYgiAukMOsCtYdn2U4uNTL0QJcrH0E1oiNRXhY5VgqQDmGBJvHv0tckmbYF4u3nUVy88aAzS7Hvfk50WRRZsiDlzmrWx2-wj54zsFYlzLZ7Lp0evbQW1jp8ceGdtGEDE0
REDACTED add address=192.168.19.29 comment="Smart-Switch1 (Driveway Lights)"  mac-address=00:00:00:00:00:00 server=DHCP_VLAN19

# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBONS9ZRktvMlZjNHFzNUpqUm96OXlYWU1NM0Z1bUJsWHBrSTJZTjVxRVhnCkR0VEdVNFNraFlkT3E0VmZKOUdFV0doQUlPVDJEUFFCVXdiRlIydFZtUkUKLT4gWDI1NTE5IFpsSjl5M3VGTWJPNmlHMXMxbkIxWCtSc29pV2pVNmQyU215RTZLcGs1RkEKZWxJQWxHWURRUE5OSW9UNkhnVVZOQWU3TSszK3pZSjFxZzdiR3R6Q1M4RQotPiBOc3N7ZS1ncmVhc2UgRXtgXTwgPUMgIgo1blFxNmp5emhUMVRxT0d6emgxaUpaZHhoRzA2ZXdCNkt6YTZiRUc1RkJtT01pNzdTbjl1ZFNrMXBaT3c1dGhnCmZyZHNDUDFXVk14Y281QmdhdXZvck5QdVlYT2FFMDZSR0swUkVDNkp6OFc5bWtKUVh3N0JTRU0KLS0tIEhmYmYra0ZOUEx1TnBZbThmcDhpWkx2WUxFUmVnNWJMbVpIOVJuMy9zMWsK0DxIF9inrx9eIRiIVWWJaudgZmsx8ys7eymcOKM1ZXOQMfC4-5UzdUc-A5emH5x-xs8MlQOirHqCA9tBD04wmbhtx7wHS1EBQn_LSjZhqeVJ7pdzR12zIcwg7GeCalRHLANkwrXIeH0GmdNIFTqzjGZSm-1NRa-mXXdo0MQY_ZRLrnJW-cArL5lBXc2iJ8IQfcapgYs
REDACTED add address=192.168.19.30 comment="Smart-TV2 (Office)"               mac-address=00:00:00:00:00:00 server=DHCP_VLAN19

# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBlOGFiblNYQlpJVjdVdGo5SFd3a2JUck9seGhqaWJoSkE2SmFtd1ZVWEVvCnd4elk4K3hSWEZqU0EzTUJBandoOVJFNnZpd0srNlFJekprd2VoVnByOG8KLT4gWDI1NTE5IFVHNDdSUVg2MHN5YXVGWEJoR0xaWGxHd25xd0Vqd0EyZzVHRlVUZmE4aHcKQlM1MzJtSlFlTEJHVmZtckgwcmpmeEI3blMvblY0MG55czVyZ1VwY2M3MAotPiBSL2FKLWdyZWFzZSBjQiBWa1ogZXtfcEh7ICRAcipBCmJLcWV1cXQ5bk1xaHZ2WE51bHlzRmtGTnBBOVdoNFVaN0xQbHhxcnZPU1o0bGZNMUZ1djcwa1VZWlh4dDJnSDgKcy9ZcURhejJCdWhkQ3cKLS0tIHI3VWp6V2l3dTloL2tkYk9xWmlSWjk1UVFNMEx5YUtNNklEZXRJRVlpbzAKL8SlIaMio7LEabLfPtY1PNCi5Ul79dZ4uPv-So0514WSQBE1j_GKgbMbD7As1yXZAipJmugWcjR95DdXawZkEMlyd0d1_xYNw7kJbnoftTboepbbgXP7fh1Q9Wih6r2ddGGtm5lZAZbtRYc2-JQyqQf7UbZCkRwgcK4QnC-GO8gi-dQpjGdjgpoeNEfLHoGOK18u1R0
REDACTED add address=192.168.19.32 comment="Thermostat1"                      mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBuN1pUWGRmajJaa21hRUlLcXZFYVZBMmlyb0NWdHo4MExxMkE5SW9OODJNCnFrbjhrdXp0RC9FcTlvZFdtNjhaRzk0dUx3TDcvVnhhYlJVNUxoaTU3TEkKLT4gWDI1NTE5IGh3WFU4S0F5SmltRVlYeCs0VFZrdXMyUDQyUXhvRGF6MWo2ZlV1bkpKQTQKODFaZTZoOTY4QlR2akZYNHdvMjl0alA3N005TGNEdGQrSm9hQS9HVGI1bwotPiBfbUIzSC5ALWdyZWFzZSBbQjkhS1dsIHtUOD1-SEtLICZ1WgptYkF0MXZMKzQ0bmRzL3h1aE9ud0d0L09PeU9PeVNZOFZxZ08velUvd3VsRklmb2pNVFE3VmhzYzMvMWxIR09jCm5oYXYwUWxsNGtmc05DRFVrcnhrRTVBMU5sTFpGeUJya2Z0cjlWRlFxaDgKLS0tIHduV1JiMTFrQWVpY1JmcVh3TEh4RTY0azA1eTg2bW5IRWZhZGNoZnRBczQKbPCv_Q7tHzQmAE2x9aO_PETOIabpvD9Jr0UdQVvGWua4HhFtLZ08I-OO2LfDLDz6dYcEoMqmGYS3TFD7oaE2r1F51R7sI6yp5Sp2WikyJDfIIWS_Vri8y3z91YS3n9AfK3QkK-8t8BqKohhYKt0gEkxE_wi2KWxv7Hq13Q7faMlPQzjzfWzLrGtF3n0PUiYXETcGudQ
REDACTED add address=192.168.19.33 comment="TV-Lights1 (Govee)"               mac-address=00:00:00:00:00:00 server=DHCP_VLAN19
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSAreGRzN0Iwa1hHYzh0NDJqYWJDM3UwV1N4RnpDcWl5YW9sUTkwa0lKbGxRCmllV3N3MFJSSElWVzlRNjUrN0FXZVlVR2pZditJQlc2TmRSQmgvdGpJbHMKLT4gWDI1NTE5IG9NSFJnczhDRDVicXN0eTE1d1RtMTNTdElrNi9Ld2JOYUs4UEdlODBHVk0KZE5rZTA0UlArQTJqOWpPOEZGZ1NwOU54eUJvWU1VQmVSanVYSUJUR3lXcwotPiBQe0poYC1ncmVhc2UKNVExR0dYTGtwYkg4cll5NWphRFN2OWRwcG5XS2M1STZSZVpQTjlIbTExNGZuWDQKLS0tIGRpZTRkU2J0N2VSbmJOWnVPaU5JZVhuM2c1L0lGYXJWOFVRV0lTaWJPOVkKaGSVtp0xDfNTkBANPQz1UVUIuhASx9tj1nv2zoQepqTGwcBBA0Y8vg3VeEcc9T5Fm6nva_yLDiBDScc-JW-SCYHwzPIzsX9-jFaBdJ3lvENw2xyVyUyXtEZ28ZHShjle_E5x10u1_8d3k738RkRcQT2Uf4_Xts0oUvfHsDlVBXPXPxMAOtP27N9EV2p-lWBtqMG_pxI
REDACTED add address=192.168.19.34 comment="Vacuum1"                          mac-address=00:00:00:00:00:00 server=DHCP_VLAN19

## Internal - Devices ###
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSBuTFF2MTkwWHVJdC82TXdFYkg5ckl6d3lwSVNQa0hLTXlwZHdOcldqSjBnCnJPd2c3eHA4NzlCZFVnUzNHazBWRW8zNVZpRGdTVjc0NVVDa1BZb0VVMXMKLT4gWDI1NTE5IFgxMUN4Sllkd0w0djlqMU92NklxMFNOdFhZRWNlSmhvVFVHNk91Z1RDU0kKNTVCVU83L2p5SWdqbisrZmI3dDlZcVB6TjR0dEVBZ01JNVVXTDJMYXJvbwotPiA0LWdyZWFzZSB9PiBHdXJhbEggWk45fjkvaiQgfTNDdmw4ClA0cWdPVFZkMzlvTHZOdHpkNUp0SDkwVXhSWERONEZxMmk3Y0U2RENmeEJaWEdwelp1clVwSDRSTTdCcnJYNVkKM1FNSQotLS0gdll6amdGaUMvc1RKbDlOeDMyNjBzbGtQN2V1NGMrNVNRQ1ZHV25HQWZhUQpa2kxX_-J5nEkdtJwbJi827ATfDGM7Kzf7HGQHCUbaKJH0ayu78UZo_FES4nOFFSut-Ada67ck-KmhjXQB_09fBBL3Eiho3YOjjMalqEJqYMFYDrMfVR1U9bo8jYclblQ-vthCo5FOWqLIBMIle4749h2zQYKQcLHn5GCE
REDACTED add address=192.168.20.2 comment="Printer1" mac-address=00:00:00:00:00:00 server=DHCP_VLAN20
# confcrypt v2 YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0-IFgyNTUxOSB3QWJxbldBaUNVY0svU0tkanIySzJkeHNRN1FHbG4xTzJsbksrbGpWemgwClVaUnU2UzNJSDlIYWhpeUpSbW9sb3FGeXA2UFNmRm9aTk9LcnRjMTZ3SFUKLT4gWDI1NTE5IDVrV1ZzdlpOaTJPWS9DdkViU2p3SjBNVi9hZzRIekl3V1hnT1Y5MVIyVTAKZnJiK3NQVmRUdXUzZVBCNHBKa0JVYkE0MCtkRGMxNDY5NlVNZWdWZ3VGSQotPiBCR2gtZC1ncmVhc2UgRispNSB2bUcKRnlDZ0pFNXd4LzMydkVyajMvdndQK0crMlVHQ2s5bmdUZVpBNEk1a0xqdjZpazNtZ2FYRVRvdVQxaVFFZjVuNQpCS0hTN05WblR2SXJka25zQ0czNG9PY0RUQ3Z1MDlmRAotLS0gZmlySjVsbGMzZ09Lem5lQzdqNTlDRlJrRUZNVkkvdVVGbmNqcTNJWlU1MApblG56gLQ-Cd2hEGbpoRT1tnAliU0D8O09DClMfyfDaerVE2yNTw3nvg-R_fMFxa0NhWbboZvpSFT6TxbD--KeY0WjjQ4L-8iEGTo_ITiepfJ4RpzuudJEs7wG1rOkKauBDuE_F3Yvuoi4LcWqXp5MgZ1V6O1fi07de2ZE
REDACTED add address=192.168.20.3 comment="Printer2" mac-address=00:00:00:00:00:00 server=DHCP_VLAN20

# Remove Default Admin User
/user remove admin
