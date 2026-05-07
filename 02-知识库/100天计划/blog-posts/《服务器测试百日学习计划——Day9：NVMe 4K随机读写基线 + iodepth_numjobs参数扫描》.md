大家好，我是JACK，本篇是服务器测试百日学习计划Day9。

Day8 建立了 nvme0n1 的顺序读写基线（写 ~4.6 GiB/s，读 ~6.8 GiB/s）。今天换成 4K 小块随机 IO，分三步来做：先建 4K 随机基线，再做 iodepth 扫描，最后做 numjobs 扫描——彻底搞清楚同一块盘在不同参数下性能怎么变。

---

## 一、顺序和随机的区别

先把定位分清楚：

| 测试类型 | 核心指标 | 典型场景 |
|---------|---------|---------|
| 顺序（Day8） | 带宽 GiB/s | 大文件备份、日志写入、视频流 |
| 随机（Day9） | IOPS、延迟 | 数据库、AI推理数据加载、虚拟机 |

> 💡 **顺序看带宽，随机看 IOPS 和延迟。** 4K × 326k IOPS ≈ 1272 MiB/s，比 Day8 的 6818 MiB/s 小很多，但这不是盘变差了，是场景不同。

---

## 二、fio 基线参数

| 参数 | 值 | 说明 |
|------|----|------|
| bs | 4K | 小块随机，典型数据库 IO |
| iodepth | 32 | 基线标准深度，与 Day8 一致 |
| numjobs | 1 | 单任务 |
| direct | 1 | 绕过页缓存，测盘本身 |
| ioengine | libaio | 异步 IO |
| offset / size | 4G / 20G | 与 Day8 保持一致 |
| runtime | 60 | 跑满 60 秒 |

全程配合 `iostat -x 1 nvme0n1`，重点盯 `r/s`、`w/s`、`await`、`aqu-sz`（设备层实际排队深度）。

今天要关注的**延迟三件套**：
- `clat avg`：平均完成延迟
- `p99 / p99.9`：尾延迟，业务体验往往由它决定
- `iostat await`：设备侧等待时间

---

## 三、4K 随机读基线

```bash
fio --name=nvme_randread_4k \
--filename=/dev/nvme0n1 --direct=1 --ioengine=libaio \
--rw=randread --bs=4K --iodepth=32 --numjobs=1 \
--offset=4G --size=20G --runtime=60 --time_based --group_reporting
```

**fio 结果：**

```
nvme_randread_4k: (groupid=0, jobs=1): err= 0: pid=14703: Fri Mar 20 13:46:24 2026
read: IOPS=326k, BW=1272MiB/s (1334MB/s)(74.6GiB/60001msec)
  slat (nsec): min=1241,  max=183453,  avg=1981.46,  stdev=900.82
  clat (usec): min=11,    max=609,     avg=95.68,    stdev=24.46
  lat  (usec): min=14,    max=778,     avg=97.75,    stdev=24.48
  clat percentiles:
   |  1.00th=[  67],  5.00th=[  72], 10.00th=[  75], 20.00th=[  79]
   | 50.00th=[  89], 90.00th=[ 133], 95.00th=[ 147]
   | 99.00th=[ 182], 99.50th=[ 196], 99.90th=[ 231], 99.99th=[ 277]
  bw (MiB/s): min=1041, max=1290, avg=1272.86, stdev=22.23, samples=119
  iops:        min=266672, max=330266, avg=325852.82, stdev=5691.06, samples=119
  cpu: usr=23.35%, sys=51.02%, ctx=150779
Disk stats: nvme0n1: ios=19504116/0, util=99.85%
```

**同步 iostat 数据：**

```
Device    r/s         rkB/s        r_await  rareq-sz  aqu-sz   %util
nvme0n1   326363.67   1305454.67   0.08     4.00      26.11    100.00
nvme0n1   324840.00   1299360.00   0.08     4.00      25.96    100.00
```

---

## 四、4K 随机写基线

```bash
fio --name=nvme_randwrite_4k \
--filename=/dev/nvme0n1 --direct=1 --ioengine=libaio \
--rw=randwrite --bs=4K --iodepth=32 --numjobs=1 \
--offset=4G --size=20G --runtime=60 --time_based --group_reporting
```

**fio 结果：**

```
nvme_randwrite_4k: (groupid=0, jobs=1): err= 0: pid=14706: Fri Mar 20 13:48:18 2026
write: IOPS=319k, BW=1247MiB/s (1308MB/s)(73.1GiB/60001msec)
  slat (nsec): min=1140,  max=266778,  avg=1816.41,  stdev=592.14
  clat (usec): min=10,    max=532,     avg=97.64,    stdev=3.63
  lat  (usec): min=11,    max=536,     avg=99.56,    stdev=3.70
  clat percentiles:
   |  1.00th=[  92],  5.00th=[  94], 10.00th=[  95], 20.00th=[  96]
   | 50.00th=[  98], 90.00th=[ 101], 95.00th=[ 102]
   | 99.00th=[ 104], 99.50th=[ 108], 99.90th=[ 147], 99.99th=[ 163]
  bw (MiB/s): min=1128, max=1300, avg=1247.87, stdev=20.10, samples=119
  iops:        min=288792, max=332984, avg=319454.54, stdev=5144.56, samples=119
  cpu: usr=29.02%, sys=47.65%, ctx=176
Disk stats: nvme0n1: ios=46/19113033, util=97.72%
```

**同步 iostat 数据：**

```
Device    w/s         wkB/s        w_await  wareq-sz  aqu-sz  %util
nvme0n1   316184.33   1264737.33   0.01     4.00      2.63    97.87
nvme0n1   323956.67   1295826.67   0.01     4.00      2.63    98.67
```

---

## 五、4K 混合随机读写（70% 读 / 30% 写）

```bash
fio --name=nvme_randrw_4k \
--filename=/dev/nvme0n1 --direct=1 --ioengine=libaio \
--rw=randrw --rwmixread=70 --bs=4K --iodepth=32 --numjobs=1 \
--offset=4G --size=20G --runtime=60 --time_based --group_reporting
```

**fio 结果：**

```
nvme_randrw_4k: (groupid=0, jobs=1): err= 0: pid=14711: Fri Mar 20 13:50:01 2026
read:  IOPS=223k,  BW=872MiB/s  (914MB/s)  (51.1GiB/60001msec)
  clat (usec): avg=120.89, stdev=46.01
  clat percentiles:
   | 50th=[ 111], 99th=[ 326], 99.9th=[ 404], 99.99th=[ 881]

write: IOPS=95.7k, BW=374MiB/s (392MB/s)  (21.9GiB/60001msec)
  clat (usec): avg=43.67, stdev=12.70
  clat percentiles:
   | 50th=[  45], 99th=[  69], 99.9th=[  94], 99.99th=[ 111]

  cpu: usr=24.66%, sys=50.87%
Disk stats: nvme0n1: ios=13356665/5724941, util=99.85%
```

**同步 iostat 数据：**

```
Device    r/s         rkB/s       r_await  w/s        wkB/s       w_await  aqu-sz  %util
nvme0n1   223077.33   892309.33   0.09     95592.33   382369.33   0.01     20.45   100.00
nvme0n1   226052.33   904209.33   0.09     96546.67   386186.67   0.01     20.63   100.00
```

---

## 六、基线汇总

| 测试项 | IOPS | BW | clat avg | p99 | await | util |
|--------|------|----|---------|-----|-------|------|
| randread_4k | **326k** | 1272 MiB/s | 95.68 μs | 182 μs | 0.08 ms | 99.85%~100% |
| randwrite_4k | **319k** | 1247 MiB/s | 97.64 μs | 104 μs | 0.01 ms | 97.72%~98.67% |
| randrw_4k 70/30 | 读 **223k** / 写 **95.7k** | 读 872 / 写 374 MiB/s | 读 120.89 / 写 43.67 μs | 读 326 / 写 69 μs | r:0.09 / w:0.01 ms | 99.85%~100% |

fio IOPS 和 iostat r/s、w/s 全程对齐，结果可信。

---

## 七、参数扫描：iodepth 对性能的影响

有了基线，继续深挖——**同一块盘，iodepth 一变，性能怎么变？**

**测试设计：** 固定 rw=randread、bs=4K、numjobs=1，只改 iodepth，覆盖 QD=1 / 8 / 32 / 64。

### QD=1

```bash
fio --name=randread_4k_qd1 ... --iodepth=1 ...
```

```
read: IOPS=12.5k, BW=48.8MiB/s (51.2MB/s)(2930MiB/60001msec)
  clat (nsec): avg=76407.55, stdev=11639.08
  clat percentiles:
   | 50th=[75 us], 99th=[91 us], 99.9th=[101 us], 99.99th=[135 us]
  cpu: usr=1.05%, sys=2.89%
  util=92.00%
```

**iostat：** r/s=12,397~12,645 / await=0.07~0.08 ms / **aqu-sz=0.94** / util=90.93%~92.67%

---

### QD=8

```bash
fio --name=randread_4k_qd8 ... --iodepth=8 ...
```

```
read: IOPS=109k, BW=426MiB/s (446MB/s)(24.9GiB/60001msec)
  clat (usec): avg=71.08, stdev=15.89
  clat percentiles:
   | 50th=[67 us], 99th=[129 us], 99.9th=[155 us], 99.99th=[190 us]
  cpu: usr=11.15%, sys=18.34%
  util=99.85%
```

**iostat：** r/s=108,452~108,524 / await=0.07 ms / **aqu-sz=7.56** / util=100%

---

### QD=32（复用基线数据）

IOPS=330k / BW=1288 MiB/s / clat avg=94.5 μs / p99=178 μs / **aqu-sz=25.96** / util=100%

---

### QD=64

```bash
fio --name=randread_4k_qd64 ... --iodepth=64 ...
```

```
read: IOPS=336k, BW=1312MiB/s (1376MB/s)(76.9GiB/60001msec)
  clat (usec): avg=188.03, stdev=27.43
  clat percentiles:
   | 50th=[184 us], 99th=[277 us], 99.9th=[338 us], 99.99th=[400 us]
  cpu: usr=25.27%, sys=50.58%
  util=99.85%
```

**iostat：** r/s=337,350~337,512 / await=0.08 ms / **aqu-sz=26.26~26.31** / util=100%

---

### iodepth 扫描汇总

| iodepth | IOPS | BW | clat avg | p99 | aqu-sz | util |
|---------|------|----|---------|-----|--------|------|
| 1 | 12.5k | 48.8 MiB/s | 76.4 μs | 91 μs | 0.94 | ~92% |
| 8 | 109k | 426 MiB/s | 71.1 μs | 129 μs | 7.56 | 100% |
| 32 | 330k | 1288 MiB/s | 94.5 μs | 178 μs | 25.96 | 100% |
| **64** | **336k** | 1312 MiB/s | **188.0 μs** | **277 μs** | **26.3** | 100% |

> ⚠️ **QD64 的 aqu-sz 停在 26，没跟到 64。** 说明设备层实际排队深度已到上限，再加深 iodepth 只是让请求在软件层空转——IOPS 只涨了 1.8%，但 clat avg 翻倍，p99 涨 56%。**甜点区在 QD32。**

---

## 八、参数扫描：numjobs 对性能的影响

iodepth 固定 32，只改 numjobs，看多路并发能带来多少额外收益。

### jobs=2

```bash
fio --name=randread_4k_jobs2 ... --iodepth=32 --numjobs=2 ...
```

```
read: IOPS=596k, BW=2330MiB/s (2443MB/s)(137GiB/60001msec)
  clat (usec): avg=104.80, stdev=38.21
  clat percentiles:
   | 50th=[ 92 us], 99th=[233 us], 99.9th=[302 us], 99.99th=[371 us]
  cpu: usr=22.25%, sys=47.10%
  util=99.84%
```

**iostat：** r/s=593,856~594,020 / await=0.10 ms / **aqu-sz=57.18~57.24** / util=100%

---

### jobs=4

```bash
fio --name=randread_4k_jobs4 ... --numjobs=4 ...
```

```
read: IOPS=903k, BW=3525MiB/s (3697MB/s)(207GiB/60001msec)
  clat (usec): avg=139.40, stdev=63.02
  clat percentiles:
   | 50th=[127 us], 99th=[338 us], 99.9th=[449 us], 99.99th=[570 us]
  cpu: usr=18.99%, sys=37.01%
  util=99.84%
```

**iostat：** r/s=905,452~909,869 / await=0.13 ms / **aqu-sz=121.53~121.56** / util=100%

---

### jobs=8

```bash
fio --name=randread_4k_jobs8 ... --numjobs=8 ...
```

```
read: IOPS=1199k, BW=4683MiB/s (4911MB/s)(274GiB/60001msec)
  clat (usec): avg=211.27, stdev=101.44
  clat percentiles:
   | 50th=[196 us], 99th=[545 us], 99.9th=[742 us], 99.99th=[971 us]
  cpu: usr=14.05%, sys=24.72%
  util=100%
```

**iostat：** r/s=1,198,804~1,200,131 / await=0.21 ms / **aqu-sz=250.02~250.18** / util=100%

---

### numjobs 扫描汇总

| numjobs | 总并发(×32) | IOPS | BW | clat avg | p99 | aqu-sz | util |
|---------|------------|------|----|---------|-----|--------|------|
| 1 | 32 | 330k | 1288 MiB/s | 94.5 μs | 178 μs | 25.96 | 100% |
| 2 | 64 | 596k（+80%）| 2330 MiB/s | 104.8 μs | 233 μs | 57.24 | 100% |
| 4 | 128 | 903k（+51%）| 3525 MiB/s | 139.4 μs | 338 μs | 121.56 | 100% |
| 8 | 256 | **1199k**（+33%）| 4683 MiB/s | 211.3 μs | **545 μs** | 250.18 | 100% |

---

## 九、结果解读

### 1. aqu-sz 是验证参数的钥匙

fio 设的 iodepth × numjobs 和 iostat aqu-sz 应该能对上：

| 设置 | 理论并发 | 实测 aqu-sz | 说明 |
|------|---------|------------|------|
| QD1, jobs=1 | 1 | 0.94 | ✅ 对上 |
| QD8, jobs=1 | 8 | 7.56 | ✅ 对上 |
| QD32, jobs=1 | 32 | 25.96 | ✅ 对上 |
| QD64, jobs=1 | 64 | **26.3** | ⚠️ 没跟上，盘到顶了 |
| QD32, jobs=2 | 64 | 57.24 | ✅ 对上 |
| QD32, jobs=4 | 128 | 121.56 | ✅ 对上 |
| QD32, jobs=8 | 256 | 250.18 | ✅ 对上 |

QD64 aqu-sz 停在 26 是关键证据——盘的并发能力已到极限，继续加深 iodepth 只是在软件层堆积，性能收益接近于零。

### 2. iodepth 甜点区在 QD32

- QD1→QD8：IOPS 涨 8.7 倍，平均延迟反而略降（NVMe 内部并行激活）
- QD8→QD32：IOPS 继续涨 3 倍，延迟开始抬头
- QD32→QD64：IOPS 仅 +1.8%，clat avg 翻倍，p99 +56%

### 3. numjobs 收益递减，尾延迟优先恶化

- jobs=1→2：+80% IOPS，p99 从 178→233 μs
- jobs=2→4：+51% IOPS，p99 从 233→338 μs
- jobs=4→8：+33% IOPS，p99 从 338→**545 μs**

多 job 能持续换来 IOPS，但每轮收益缩减，p99 恶化却在加速。**追求极限吞吐选 jobs=8，追求吞吐/延迟均衡选 jobs=2~4。**

### 4. 随机写的尾延迟出奇地好

randwrite p99=104 μs，比 randread 的 182 μs 更低，而且延迟极为集中（stdev=3.63 vs 24.46）。aqu-sz 只有 2.63 就跑出了 319k IOPS，说明这块盘的写操作内部调度路径非常规整。

---

## 十、本机 nvme0n1 随机性能基线总结

**标准参数（bs=4K, iodepth=32, numjobs=1, direct=1）：**

- 4K 随机读：**326k IOPS** / 1272 MiB/s / p99=182 μs
- 4K 随机写：**319k IOPS** / 1247 MiB/s / p99=104 μs
- 4K 混合 70/30：读 **223k IOPS**，写 **95.7k IOPS**

**极限参数（bs=4K, iodepth=32, numjobs=8）：**

- 4K 随机读：**1199k IOPS** / 4683 MiB/s / p99=545 μs

---

## 总结

Day9 三条核心结论：

**一、随机看 IOPS 和延迟，重点盯 p99，不要只看平均值。** 业务体验往往由尾延迟决定，p99=182 μs 和 p99=545 μs 对业务的感受完全不同。

**二、iodepth 有甜点区，这块盘在 QD32。** aqu-sz 停在 26（而不是跟到 64）是最直接的证据，继续堆队列深度性价比极低。

**三、numjobs 换吞吐，但要付出 p99 代价，而且代价递增。** 设计压测参数时，先想清楚业务是吞吐优先还是延迟优先，再决定 numjobs 取几。

下一篇进入网络测试，看 25GbE 网卡带宽怎么测，敬请期待！

欢迎关注 **JACK的服务器笔记**，我们下篇见！
