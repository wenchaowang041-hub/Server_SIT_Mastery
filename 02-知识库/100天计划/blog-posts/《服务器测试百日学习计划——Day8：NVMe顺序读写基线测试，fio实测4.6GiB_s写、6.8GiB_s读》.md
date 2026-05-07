大家好，我是JACK，本篇是服务器测试百日学习计划Day8。

Day7 我们搞清楚了RAID控制器和存储路径，今天开始对 NVMe 盘动真格——用 fio 跑 4 组顺序读写基线，同时用 iostat 交叉验证，建立 nvme0n1 的性能基准数据。

## 一、测试前准备

### 确认测试盘

本次测试目标盘是 **nvme0n1**（3.2TB DERA NVMe），nvme1n1 是运行中的 openEuler 系统盘，**绝对不能碰**。

```bash
[root@bogon ~]# lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0   2.9T  0 disk              ← 测试盘（无分区挂载）
nvme1n1     259:1    0   2.9T  0 disk
├─nvme1n1p1           600M  0 part /boot/efi
├─nvme1n1p2             1G  0 part /boot
└─nvme1n1p3           2.9T  0 part
  ├─openeuler-root     70G  0 lvm  /
  ├─openeuler-swap      4G  0 lvm  [SWAP]
  └─openeuler-home    2.8T  0 lvm  /home
```

nvme0n1 无分区无挂载，可以安全作为测试盘。

### 清理测试盘

```bash
# 清除分区表签名
wipefs -a /dev/nvme0n1

# 通知内核更新分区信息
partprobe /dev/nvme0n1
```

### 开启 iostat 监控窗口

另开一个终端，全程保持监控，与 fio 数据交叉验证：

```bash
iostat -x 1 nvme0n1
```

重点关注列：`rkB/s`、`wkB/s`、`r_await`、`w_await`、`aqu-sz`、`%util`

---

## 二、fio 参数说明

| 参数 | 值 | 说明 |
|------|----|------|
| direct=1 | 绕过页缓存 | 直接测盘本身，排除OS缓存干扰 |
| ioengine=libaio | 异步IO引擎 | Linux异步IO，企业级测试标准 |
| iodepth=32 | 队列深度32 | NVMe多队列优势场景 |
| numjobs=1 | 单任务 | 单线程顺序IO，测盘本身上限 |
| offset=4G | 跳过前4G | 避开分区表区域 |
| size=20G | 测试数据量 | 足够大确保结果稳定 |
| runtime=60 | 运行60秒 | time_based模式，跑满60秒 |

---

## 三、4 组顺序读写基线测试

### 第1组：1M 顺序写

```bash
fio --name=nvme_seq_write_1m \
--filename=/dev/nvme0n1 \
--direct=1 --ioengine=libaio \
--rw=write --bs=1M --iodepth=32 \
--numjobs=1 --offset=4G --size=20G \
--runtime=60 --time_based --group_reporting
```

**fio 结果：**

```
nvme_seq_write_1m: (groupid=0, jobs=1): err= 0: pid=14540: Fri Mar 20 12:45:10 2026
write: IOPS=4626, BW=4627MiB/s (4852MB/s)(271GiB/60007msec)
  clat (usec): min=3854, max=18596, avg=6894.93, stdev=643.90
  clat percentiles:
   | 50.00th=[ 6849], 90.00th=[ 7177], 99.00th=[10028], 99.99th=[17957]
  bw (MiB/s): min=2684, max=4714, avg=4628.34, stdev=181.55, samples=119
  cpu: usr=7.19%, sys=2.59%
Disk stats: nvme0n1: util=99.84%
```

**同步 iostat 数据：**

```
Device   w/s      wkB/s       w_await  wareq-sz  aqu-sz  %util
nvme0n1  4765.00  4731904.00  6.90     993.05    32.88   100.00
nvme0n1  4791.00  4757504.00  6.86     993.01    32.88   100.00
```

---

### 第2组：1M 顺序读

```bash
fio --name=nvme_seq_read_1m \
--filename=/dev/nvme0n1 \
--direct=1 --ioengine=libaio \
--rw=read --bs=1M --iodepth=32 \
--numjobs=1 --offset=4G --size=20G \
--runtime=60 --time_based --group_reporting
```

**fio 结果：**

```
nvme_seq_read_1m: (groupid=0, jobs=1): err= 0: pid=14552: Fri Mar 20 12:47:23 2026
read: IOPS=6818, BW=6818MiB/s (7149MB/s)(400GiB/60003msec)
  clat (usec): min=1425, max=12244, avg=4686.91, stdev=258.10
  clat percentiles:
   | 50.00th=[ 4686], 90.00th=[ 4817], 99.00th=[ 4883], 99.99th=[11994]
  bw (MiB/s): min=5518, max=6836, avg=6820.13, stdev=120.40, samples=119
  cpu: usr=1.06%, sys=3.62%
Disk stats: nvme0n1: util=99.85%
```

**同步 iostat 数据：**

```
Device   r/s     rkB/s       r_await  rareq-sz  aqu-sz  %util
nvme0n1  7044.00 6990848.00  4.67     992.45    32.92   100.00
nvme0n1  7041.00 6992896.00  4.67     993.17    32.92   100.00
```

---

### 第3组：128K 顺序写

```bash
fio --name=nvme_seq_write_128k \
--filename=/dev/nvme0n1 \
--direct=1 --ioengine=libaio \
--rw=write --bs=128K --iodepth=32 \
--numjobs=1 --offset=4G --size=20G \
--runtime=60 --time_based --group_reporting
```

**fio 结果：**

```
nvme_seq_write_128k: (groupid=0, jobs=1): err= 0: pid=14555: Fri Mar 20 12:48:46 2026
write: IOPS=37.0k, BW=4630MiB/s (4855MB/s)(271GiB/60001msec)
  clat (usec): min=442, max=5069, avg=858.64, stdev=195.18
  clat percentiles:
   | 50.00th=[ 840], 90.00th=[ 1090], 99.00th=[ 1205], 99.99th=[ 3884]
  bw (MiB/s): min=2956, max=4699, avg=4631.31, stdev=157.03, samples=119
  cpu: usr=11.54%, sys=10.54%
Disk stats: nvme0n1: util=99.85%
```

**同步 iostat 数据：**

```
Device   w/s      wkB/s       w_await  wareq-sz  aqu-sz  %util
nvme0n1  36939.00 4728192.00  0.86     128.00    31.79   100.00
nvme0n1  37106.00 4749568.00  0.86     128.00    31.80   100.00
```

---

### 第4组：128K 顺序读

```bash
fio --name=nvme_seq_read_128k \
--filename=/dev/nvme0n1 \
--direct=1 --ioengine=libaio \
--rw=read --bs=128K --iodepth=32 \
--numjobs=1 --offset=4G --size=20G \
--runtime=60 --time_based --group_reporting
```

**fio 结果：**

```
nvme_seq_read_128k: (groupid=0, jobs=1): err= 0: pid=14561: Fri Mar 20 12:50:15 2026
read: IOPS=54.5k, BW=6811MiB/s (7141MB/s)(399GiB/60001msec)
  clat (usec): min=38,  max=3143, avg=583.19, stdev=130.97
  clat percentiles:
   | 50.00th=[ 570], 90.00th=[ 758], 99.00th=[ 865], 99.99th=[ 2057]
  bw (MiB/s): min=5623, max=6825, avg=6812.69, stdev=110.15, samples=119
  cpu: usr=6.28%, sys=17.78%
Disk stats: nvme0n1: util=99.85%
```

**同步 iostat 数据：**

```
Device   r/s      rkB/s       r_await  rareq-sz  aqu-sz  %util
nvme0n1  54568.00 6984704.00  0.58     128.00    31.68   100.00
nvme0n1  54575.00 6985600.00  0.58     128.00    31.66   100.00
```

---

## 四、基线汇总表

| 测试项 | bs | iodepth | rw | fio带宽 | iostat带宽 | await | util |
|--------|----|---------|----|---------|------------|-------|------|
| seq_write_1m | 1M | 32 | write | **4627 MiB/s** | 4,731,904~4,757,504 kB/s | 6.86~6.90 ms | 99.84%~100% |
| seq_read_1m | 1M | 32 | read | **6818 MiB/s** | 6,990,848~6,992,896 kB/s | 4.67 ms | 99.85%~100% |
| seq_write_128k | 128K | 32 | write | **4630 MiB/s** | 4,728,192~4,749,568 kB/s | 0.86 ms | 99.85%~100% |
| seq_read_128k | 128K | 32 | read | **6811 MiB/s** | 6,984,704~6,985,600 kB/s | 0.58 ms | 99.85%~100% |

---

## 五、结果解读

### 1. fio 与 iostat 数据对齐——结果可信

以 1M 顺序写为例：

- fio 带宽：4627 MiB/s ≈ 4627 × 1024 = **4,738,048 kB/s**
- iostat wkB/s：**4,731,904 ~ 4,757,504 kB/s**

两者完全吻合。延迟也对齐：fio clat avg = 6894 μs ≈ **6.9 ms**，iostat w_await = **6.86~6.90 ms**。

> 💡 **fio 是应用视角**（从提交IO到完成），**iostat 是设备视角**（内核块层统计）。两者对齐，说明测试盘选对了、数据打在了 nvme0n1 上、结果可信。这是性能测试的基本验证手段。

### 2. 读带宽明显高于写带宽

顺序读 ≈ 6.8 GiB/s，顺序写 ≈ 4.6 GiB/s，读写比约 1.47:1。这是 NVMe SSD 的普遍特性：读操作直接从闪存取数据，写操作需要经历擦除-写入周期，内部管理更复杂，速度自然低一些。

### 3. bs 大小对延迟和 IOPS 影响显著

| | 1M 顺序写 | 128K 顺序写 |
|--|-----------|------------|
| 带宽 | 4627 MiB/s | 4630 MiB/s |
| await | 6.86 ms | 0.86 ms |
| IOPS | 4,626 | 37,000 |

bs 从 1M 降到 128K，**带宽几乎不变**，但 await 下降 8 倍，IOPS 增加 8 倍。说明这块盘的顺序吞吐上限已经被摸到了，瓶颈在盘本身，不在块大小。

### 4. %util 和 aqu-sz 说明什么

- `%util ≈ 100%`：设备忙碌度饱和，这组参数下盘已到上限
- `aqu-sz ≈ 32`：队列中平均有32个IO等待，与 iodepth=32 完全吻合
- `CPU usr/sys < 12%`：CPU压力很小，瓶颈在盘，不在CPU

### 5. IOPS 和带宽的关系验证

1M 顺序写：IOPS = 4626，bs = 1M → 4626 × 1 MiB = **4626 MiB/s**，与带宽完全一致。这是 fio 输出自洽的基本校验。

---

## 六、本机 nvme0n1 顺序读写基线结论

在 `bs=1M/128K`、`iodepth=32`、`numjobs=1`、`direct=1` 条件下：

- **顺序写基线**：约 **4.6 GiB/s**（4852 MB/s）
- **顺序读基线**：约 **6.8 GiB/s**（7149 MB/s）

fio 与 iostat 带宽、延迟数据全程对齐，%util 接近 100%，结果可信，可作为后续性能对比的参考基准。

---

## 总结

Day8 的核心收获：

- **建立了真实基线数据**：nvme0n1 顺序写 ~4.6 GiB/s、顺序读 ~6.8 GiB/s，这是这台机器这块盘的真实能力上限
- **掌握了 fio + iostat 交叉验证方法**：两个工具数据对齐才说明测试有效，这是性能测试的基本功
- **理解了 bs 与延迟的关系**：块越小，单次IO时间越短，IOPS越高；顺序场景带宽上限和块大小关系不大，瓶颈在盘本身的吞吐能力

下一篇 Day9 进入随机读写基线（4K randread/randwrite），重点看 IOPS，敬请期待！

欢迎关注 **JACK的服务器笔记**，我们下篇见！
