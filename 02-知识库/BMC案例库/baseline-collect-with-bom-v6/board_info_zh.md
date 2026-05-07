# 基准配置填写_板卡信息

| 类别 | 物料号 | 批次号 | 物料描述 | 位置 | 版本 | 数量 | 备注（*为必填项） |
|---|---|---|---|---|---|---:|---|
| MB |  |  | iSoftStone BC83AMDA01-7260Z | - | V200R023C10 | 1 | *SN 待人工补；来源：BOM+dmidecode |
| NVMe BP |  |  | NVMe Disk Backplane | 前置 | 0.02/0.02/0.02 | 3 | 当前环境为 NVMe 背板，不沿用 SATA 背板 BOM |
| Mid Riser |  |  | Mid/IO Riser | 中置/后置 | 0.04 |  | 需结合实物标签确认 |
| FAN BP |  |  | 前置风扇板 | 前置 | 0.04 | 1 | 前置风扇板，单独列示 |
| FAN BP |  |  | 中置风扇板 | 中置 | 0.03 | 1 | 中置风扇板，单独列示 |
| SCM Card |  |  | BMC/SCM board | 后置 | 11.02.01.18 | 1 | 版本来自 Redfish /Managers/1 |
| PSU Board |  |  | PSU board | 电源区域 | 5.04 | 2 | 版本来自 Redfish；不使用 PSU 模块 BOM 近似替代 |
