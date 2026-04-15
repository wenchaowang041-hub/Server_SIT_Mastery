# Plug-UnPlug Safe

这套脚本用于 Linux 下 NVMe 热插拔测试的半自动执行，特点：

- 自动排除系统盘
- 自动执行分区、UUID 绑定、起始日志、MD5、`fio`
- 循环提示人工拔盘和插盘
- 每次回插后自动执行 `md5` 校验
- 结束后自动执行日志检查

入口脚本：

- `auto-plug-unplug-fio-safe.sh`

专用操作手册：

- `Plug-UnPlug-安全版操作手册.md`
