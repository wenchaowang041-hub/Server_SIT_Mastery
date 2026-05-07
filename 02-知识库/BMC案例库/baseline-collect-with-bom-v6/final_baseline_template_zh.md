# 基准配置汇总

## 软件信息

| 类别 | 版本 | 发布时间 | 备注 |
|---|---|---|---|
| OS | openEuler 22.03 (LTS-SP4) |  | Kernel: 5.10.0-216.0.0.115.oe2203sp4.aarch64 |
| GCC | gcc (GCC) 10.3.1 |  | 自动采集 |
| BIOS | 6.02.01.05 |  | dmidecode；固件库存版本：32.70.0 |
| BMC | 11.02.01.18 |  | from Redfish /Managers/1 |
| MB CPLD | 6.12 |  | Redfish FirmwareInventory |
| 前置 FAN CPLD | 0.04 |  | Redfish FirmwareInventory |
| 中置 FAN CPLD | 0.03 |  | Redfish FirmwareInventory |
| SCM CPLD | 11.02.01.18 |  | Redfish FirmwareInventory 近似映射 |
| NVMe BP1 CPLD | 0.02 |  | Redfish FirmwareInventory |
| NVMe BP2 CPLD | 0.02 |  | Redfish FirmwareInventory |
| NVMe BP3 CPLD | 0.02 |  | Redfish FirmwareInventory |
| PSU Board CSR | 5.04 |  | Redfish FirmwareInventory |

## 板卡信息

| 类别 | 物料号 | 批次号 | 物料描述 | 位置 | 版本 | 数量 | 备注（*为必填项） |
|---|---|---|---|---|---|---:|---|
| MB |  |  | iSoftStone BC83AMDA01-7260Z | - | V200R023C10 | 1 | *SN 待人工补；来源：BOM+dmidecode |
| NVMe BP |  |  | NVMe Disk Backplane | 前置 | 0.02/0.02/0.02 | 3 | 当前环境为 NVMe 背板，不沿用 SATA 背板 BOM |
| Mid Riser |  |  | Mid/IO Riser | 中置/后置 | 0.04 |  | 需结合实物标签确认 |
| FAN BP |  |  | 前置风扇板 | 前置 | 0.04 | 1 | 前置风扇板，单独列示 |
| FAN BP |  |  | 中置风扇板 | 中置 | 0.03 | 1 | 中置风扇板，单独列示 |
| SCM Card |  |  | BMC/SCM board | 后置 | 11.02.01.18 | 1 | 版本来自 Redfish /Managers/1 |
| PSU Board |  |  | PSU board | 电源区域 | 5.04 | 2 | 版本来自 Redfish；不使用 PSU 模块 BOM 近似替代 |

## 部件信息

| 类别 | 物料号 | 批次号 | 物料描述 | Firmware | Driver | 位置 | 数量 | 备注 |
|---|---|---|---|---|---|---|---:|---|
| CPU |  |  | Kunpeng 920 7260Z |  |  | CPU Socket | 2 | CPU 型号以当前环境识别为准；未找到可直接对应的 BOM CPU 行 |
| MEM | 1000010708 | HW02 | 内存_64G_D5_5600_2Rx4_E |  |  | DIMM | 32 | 总容量 2014.1 GiB；BOM 仅补单条料号信息 |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme4n1 034XESZERB003970 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme1n1 034XESZERC000508 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme0n1 034XESZERC000419 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme3n1 034XESZERC000041 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme2n1 034XESZERC000354 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme11n1 034XESZERC000474 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme8n1 034XESZERC000513 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme7n1 034XESD9R6000101 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme6n1 034XESZERC000485 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme10n1 034XESZERC000235 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme9n1 034XESD9R6000189 1.7T |
| NVMe SSD |  |  | HWE6AP441T9L00KN |  | nvme | PCIe/NVMe | 1 | /dev/nvme5n1 034XESZERC000359 1.7T |
| OCP NIC |  |  | 四口10G电口灵活网卡 | 2.00 |  | OCP/Flex | 1 | 来自当前环境物理卡识别：35:00，4口 |
| PCIe NIC |  |  | 100G双口PCIe网卡 |  |  | PCIe | 1 | 来自当前环境物理卡识别：68:00，函数数 2 |
| OCP NIC | 1000007914 | HW00 | SF223D-H灵活网卡25G/10G 双口 _无模块 | 1.18 |  | OCP/Flex | 1 | 来自当前环境物理卡识别：75:00，2口 |

## 固件清单

| 类别 | 名称 | 版本 |
|---|---|---|
| ActiveBMCSDK | ActiveBMCSDK | 5.10.0.1 |
| ActiveBMC | ActiveBMC | 11.02.01.18 |
| ActiveSecureBootloader | ActiveSecureBootloader | 20.8.10.1 |
| ActiveSecureFirmware | ActiveSecureFirmware | 20.8.10.1 |
| ActiveUboot | ActiveUboot | 20.1.10.2 (11:42:47 Jun 18 2025) |
| AvailableBMCSDK | AvailableBMCSDK | 5.10.0.1 |
| AvailableBMC | AvailableBMC | 11.02.01.18 |
| BackupBMCSDK | BackupBMCSDK | 5.10.0.1 |
| BackupBMC | BackupBMC | 11.02.01.18 |
| BackupSecureBootloader | BackupSecureBootloader | 20.8.10.1 |
| BackupSecureFirmware | BackupSecureFirmware | 20.8.10.1 |
| BackupUboot | BackupUboot | 20.1.10.2 (11:42:47 Jun 18 2025) |
| BCU1CpuBoard1CPLD1 | CpuBoard1 CPLD1 | 6.12 |
| BCU1CpuBoard1CPLD2 | CpuBoard1 CPLD2 | 6.12 |
| BCU1CpuBoard1HWSR | CpuBoard1 CSR | 3.37 |
| BCU1CpuBoard1MCU | CpuBoard1 MCU | 2.03.02 |
| Bios | TF | 32.70.0 |
| chassisBMCPSR | Product CSR | 5.05 |
| chassisNIC1(SF221Q)HWSR | NIC 1 (SF221Q) CSR | 2.00 |
| chassisNIC2(SF223D-H)HWSR | NIC 2 (SF223D-H) CSR | 1.18 |
| chassisNIC2(SF223D-H)Retimer | chassisNIC2(SF223D-H)Retimer | N/A |
| chassisPSU1 | PSU1 | DC:1.0 PFC:1.00 |
| chassisPSU2 | PSU2 | DC:1.0 PFC:1.00 |
| chassisPSU3 | PSU3 | DC:1.0 PFC:1.00 |
| chassisPSU4 | PSU4 | DC:1.112 PFC:1.1120 |
| chassisPSU5 | PSU5 | DC:1.0 PFC:1.00 |
| chassisPSU6 | PSU6 | DC:1.0 PFC:1.00 |
| chassisPSUBoard1HWSR | PSUBoard1 CSR | 5.04 |
| chassisPSUBoard2HWSR | PSUBoard2 CSR | 5.04 |
| chassisSwitchBoard1HWSR | SwitchBoard1 CSR | 5.01 |
| CLU1FanBoard1CPLD | FanBoard1 CPLD | 0.04 |
| CLU1FanBoard1HWSR | FanBoard1 CSR | 5.04 |
| CLU2FanBoard2CPLD | FanBoard2 CPLD | 0.03 |
| CLU2FanBoard2HWSR | FanBoard2 CSR | 5.04 |
| CpuBoard1VRD | CpuBoard1 VRD | 36.36.36.36.36.36.36.36 |
| Efuse | Efuse | N/A |
| EXU1ExpBoard1CPLD | ExpBoard1 CPLD | 0.04 |
| EXU1ExpBoard1HWSR | ExpBoard1 CSR | 5.05 |
| PCIeCard10MCU | PCIe10 MCU | 3.3.0 |
| PCIeCard11MCU | PCIe11 MCU | 3.3.0 |
| PCIeCard12MCU | PCIe12 MCU | 23.2.2 |
| PCIeCard13MCU | PCIe13 MCU | 3.3.0 |
| PCIeCard1MCU | PCIe1 MCU | 3.3.0 |
| PCIeCard2MCU | PCIe2 MCU | 3.3.0 |
| PCIeCard3MCU | PCIe3 MCU | 23.2.2 |
| PCIeCard4MCU | PCIe4 MCU | 23.2.2 |
| PCIeCard5MCU | PCIe5 MCU | 23.2.2 |
| PCIeCard8MCU | PCIe8 MCU | 3.3.0 |
| SEU1DiskBP1CPLD | DiskBP1 CPLD | 0.02 |
| SEU1DiskBP1HWSR | DiskBP1 CSR | 5.04 |
| SEU2DiskBP2CPLD | DiskBP2 CPLD | 0.02 |
| SEU2DiskBP2HWSR | DiskBP2 CSR | 5.04 |
| SEU3DiskBP3CPLD | DiskBP3 CPLD | 0.02 |
| SEU3DiskBP3HWSR | DiskBP3 CSR | 5.04 |
| TeeOS | TeeOS | N/A |
