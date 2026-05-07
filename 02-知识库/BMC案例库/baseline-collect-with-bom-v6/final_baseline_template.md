# Final Baseline Template

## Software
# Software Info

| Category | Version | Release Date | Notes |
|---|---|---|---|
| OS | openEuler 22.03 (LTS-SP4) | N/A | Kernel: 5.10.0-216.0.0.115.oe2203sp4.aarch64 |
| GCC | gcc (GCC) 10.3.1 | N/A | auto collected |
| BIOS | 6.02.01.05 | N/A | dmidecode; inventory version: 32.70.0 |
| BMC | 11.02.01.18 | N/A | from Redfish /Managers/1 |
| MB CPLD | 6.12 | N/A | Redfish FirmwareInventory |
| Front FAN CPLD | 0.04 | N/A | Redfish FirmwareInventory |
| Mid FAN CPLD | 0.03 | N/A | Redfish FirmwareInventory |
| SCM CPLD | 11.02.01.18 | N/A | Redfish FirmwareInventory approximate |
| Other FW | see firmware_inventory.md | N/A | see raw logs |

## Component Spec
# Component Spec

## CPU
- Manufacturer: HiSilicon
- Model: Kunpeng 920 7260Z
- Performance: 128 cores / 256 threads
- Frequency: 2600.0000 MHz (max)
- Cache: L3 224 MiB (4 instances)

## Memory
- Manufacturer: Cxmt
- Capacity: 2014.1 GiB
- Bandwidth/Speed: 5600 MT/s
- DIMM Count: 32

## NVMe/SATA Disks

| NAME | MODEL | SERIAL | SIZE | ROTA | TYPE |
|---|---|---|---|---:|---|
| nvme4n1 | HWE6AP441T9L00KN | 034XESZERB003970 | 1.7T | 0 | disk |
| nvme1n1 | HWE6AP441T9L00KN | 034XESZERC000508 | 1.7T | 0 | disk |
| nvme0n1 | HWE6AP441T9L00KN | 034XESZERC000419 | 1.7T | 0 | disk |
| nvme3n1 | HWE6AP441T9L00KN | 034XESZERC000041 | 1.7T | 0 | disk |
| nvme2n1 | HWE6AP441T9L00KN | 034XESZERC000354 | 1.7T | 0 | disk |
| nvme11n1 | HWE6AP441T9L00KN | 034XESZERC000474 | 1.7T | 0 | disk |
| nvme8n1 | HWE6AP441T9L00KN | 034XESZERC000513 | 1.7T | 0 | disk |
| nvme7n1 | HWE6AP441T9L00KN | 034XESD9R6000101 | 1.7T | 0 | disk |
| nvme6n1 | HWE6AP441T9L00KN | 034XESZERC000485 | 1.7T | 0 | disk |
| nvme10n1 | HWE6AP441T9L00KN | 034XESZERC000235 | 1.7T | 0 | disk |
| nvme9n1 | HWE6AP441T9L00KN | 034XESD9R6000189 | 1.7T | 0 | disk |
| nvme5n1 | HWE6AP441T9L00KN | 034XESZERC000359 | 1.7T | 0 | disk |

## Board Prefill
# Board Info Prefill

| Category | Part No. | Batch No. | Description | Location | Version | Qty | Notes |
|---|---|---|---|---|---|---:|---|
| MB |  |  | iSoftStone BC83AMDA01-7260Z | - | V200R023C10 | 1 | from dmidecode |
| SCM Card |  |  | BMC/SCM board | rear | 11.02.01.18 | 1 | from Redfish/IPMI |
