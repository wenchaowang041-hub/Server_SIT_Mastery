大家好，我是JACK，本篇是Linux命令系列第四篇。上一篇我们讲了性能监控命令，这篇我们聊日志排查相关命令，结合实际工作中的排查案例来讲。

---

## 一、日志排查的重要性

在服务器测试工作中，日志是定位问题最重要的手段。遇到硬件异常、设备识别问题、测试中断等情况，第一步就是查日志。

> 💡 **重要习惯**：每次跑测试之前，先清空dmesg和SEL日志，确保测试结束后日志里全是本次测试产生的内容，排查问题不会被旧日志干扰。

---

## 二、dmesg — 内核日志

dmesg记录了系统内核运行时的所有事件，包括硬件识别、驱动加载、设备报错等，是硬件测试中最常用的日志工具。

**测试前清空dmesg：**
```bash
[root@localhost ~]# dmesg -c
# 清空当前dmesg日志，-c表示清空并打印
# 清空后跑测试，日志更干净
```

**查看dmesg日志：**
```bash
# 查看全部dmesg日志
[root@localhost ~]# dmesg

# 过滤错误日志
[root@localhost ~]# dmesg | grep -i error

# 过滤警告日志
[root@localhost ~]# dmesg | grep -i warning

# 实时监控dmesg（类似tail -f）
[root@localhost ~]# dmesg -w

# 保存dmesg日志到文件
[root@localhost ~]# dmesg > dmesg_log.txt
```

**实际案例：网卡识别异常排查**

在测试过程中遇到过网卡识别异常的情况，dmesg里会出现hns3相关报错：

```bash
[root@localhost ~]# dmesg | grep -i hns3
[    3.256789] hns3 0000:01:00.0: firmware version: 1.8.0.12
[    3.512345] hns3 0000:01:00.0: fail to initialize hw, ret = -110
[    3.513456] hns3 0000:01:00.0: probe with driver hns3 failed with error -110
# hns3是华为网卡驱动，出现probe failed说明网卡初始化失败
```

排查步骤：
```bash
# 第一步：确认网卡是否被系统识别
[root@localhost ~]# lspci | grep -i network
0000:01:00.0 Network controller: Huawei Technologies Co., Ltd. HNS GE/10GE/25GE

# 第二步：查看网卡详细报错
[root@localhost ~]# dmesg | grep -i hns3
# 根据报错信息判断是驱动问题还是硬件问题

# 第三步：检查驱动是否正常加载
[root@localhost ~]# lsmod | grep hns3
hns3                  204800  0
hclge                 458752  1 hns3
hnae3                  49152  2 hns3,hclge

# 第四步：尝试重新加载驱动
[root@localhost ~]# rmmod hns3
[root@localhost ~]# modprobe hns3
[root@localhost ~]# dmesg | grep -i hns3
# 查看重新加载后是否恢复正常
```

> 💡 **经验总结**：hns3网卡识别异常通常和驱动版本或固件版本有关，遇到这类问题先查dmesg确认报错类型，再考虑更新驱动或固件版本。

---

## 三、ipmitool sel — BMC事件日志

SEL（System Event Log）是BMC记录的系统事件日志，记录了硬件层面的所有重要事件，包括电源操作、温度告警、硬件故障等。

**测试前清空SEL日志：**
```bash
[root@localhost ~]# ipmitool sel clear
Clearing SEL buffer ... done
# 和dmesg一样，测试前先清空，保证日志干净
```

**查看SEL日志：**
```bash
# 查看所有SEL事件
[root@localhost ~]# ipmitool sel list
   1 | 03/04/2026 09:12:34 | Power Unit | Power off/down | Asserted
   2 | 03/04/2026 09:12:45 | Power Unit | Power on | Asserted
   3 | 03/04/2026 09:13:02 | Processor | IERR | Asserted
   4 | 03/04/2026 09:15:23 | Memory | Correctable ECC | Asserted
   5 | 03/04/2026 09:18:45 | Fan | Fan failure | Asserted

# 查看SEL日志条目数量
[root@localhost ~]# ipmitool sel info
SEL Information
Version          : 1.5 (v1.5, v2 compliant)
Entries          : 5
Free Space       : 16384 bytes
```

**实际案例一：验证power cycle是否执行成功**

power cycle（重启上下电）是测试中常见操作，通过SEL日志可以验证执行是否正常：

```bash
# 执行power cycle
[root@localhost ~]# ipmitool power cycle

# 服务器重启后查看SEL日志
[root@localhost ~]# ipmitool sel list
   1 | 03/04/2026 10:00:01 | Power Unit | Power off/down | Asserted
   2 | 03/04/2026 10:00:03 | Power Unit | AC lost | Asserted
   3 | 03/04/2026 10:00:15 | Power Unit | Power on | Asserted
# Power off和Power on都有记录，说明power cycle执行正常
```

**实际案例二：验证DC间隔时间**

通过SEL日志可以精确计算DC上下电的间隔时间：

```bash
[root@localhost ~]# ipmitool sel list
   1 | 03/04/2026 10:00:01 | Power Unit | Power off/down | Asserted
   2 | 03/04/2026 10:00:15 | Power Unit | Power on  | Asserted
# Power off时间10:00:01，Power on时间10:00:15
# DC间隔时间 = 14秒，确认是否符合规格要求
```

**常见SEL事件说明：**

| 事件 | 说明 |
|------|------|
| Power off/down | 服务器下电 |
| Power on | 服务器上电 |
| AC lost | 交流电源丢失 |
| Correctable ECC | 内存可纠正错误 |
| Uncorrectable ECC | 内存不可纠正错误，需更换内存 |
| Fan failure | 风扇故障 |
| Temperature | 温度告警 |
| IERR | CPU内部错误 |

---

## 四、journalctl — 系统服务日志

journalctl是systemd的日志查看工具，记录了系统服务、启动过程、应用程序等日志，比/var/log/messages更全面。

```bash
# 查看所有系统日志
[root@localhost ~]# journalctl

# 查看最新日志（类似tail）
[root@localhost ~]# journalctl -e

# 实时监控日志
[root@localhost ~]# journalctl -f

# 查看本次启动的日志
[root@localhost ~]# journalctl -b

# 查看指定服务的日志
[root@localhost ~]# journalctl -u NetworkManager

# 过滤错误级别日志
[root@localhost ~]# journalctl -p err

# 查看指定时间段的日志
[root@localhost ~]# journalctl --since "2026-03-04 09:00:00" --until "2026-03-04 10:00:00"
```

---

## 五、/var/log/messages — 系统消息日志

/var/log/messages记录了系统运行时的各类消息，包括内核消息、系统服务消息等。

```bash
# 查看系统日志
[root@localhost ~]# cat /var/log/messages

# 实时监控系统日志
[root@localhost ~]# tail -f /var/log/messages

# 搜索关键词
[root@localhost ~]# grep -i error /var/log/messages
[root@localhost ~]# grep -i hns3 /var/log/messages

# 查看最后100行
[root@localhost ~]# tail -n 100 /var/log/messages
```

---

## 六、日志排查综合流程

测试标准流程建议如下：

**测试前：**
```bash
# 清空dmesg
dmesg -c

# 清空SEL日志
ipmitool sel clear
```

**测试中：**
```bash
# 实时监控dmesg有无报错
dmesg -w

# 实时监控系统日志
tail -f /var/log/messages
```

**测试后：**
```bash
# 保存dmesg日志
dmesg > dmesg_$(date +%Y%m%d_%H%M%S).txt

# 保存SEL日志
ipmitool sel list > sel_$(date +%Y%m%d_%H%M%S).txt

# 检查关键报错
dmesg | grep -i error
dmesg | grep -i warning
ipmitool sel list | grep -i fail
```

---

## 七、总结

日志排查核心工具：
- **dmesg** — 内核硬件日志，测试前先清空，测试后检查报错
- **ipmitool sel** — BMC事件日志，验证power cycle、DC间隔时间，查看硬件告警
- **journalctl** — 系统服务日志，排查服务启动和运行问题
- **/var/log/messages** — 系统消息日志，综合排查系统异常

养成测试前清空日志、测试后保存归档的习惯，遇到问题排查效率会大幅提升。

下一篇我们聊**网络测试命令详解**，包括ethtool、iperf3实战用法，敬请期待！

欢迎关注**JACK的服务器笔记**！
