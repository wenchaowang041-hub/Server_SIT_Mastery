1.  \# 验证Device 0状态（必须确保Device在线） npu-smi info \| grep -A5 "Device 0"

    <img src="media/image1.png" style="width:5.76319in;height:0.10208in" alt="6fbd05d966ad4b015a62993a1f32f3a5" />

2、定长模式测试（固定 8MB 数据传输）每次传输 8MB 数据，迭代 100 次，统计 H2D/D2H 的带宽和时延。

\# ① Host → Device 0（H2D）：8MB/次，迭代100次 ascend-dmi --bw -t h2d -d 0 -s 8388608 --et 100<img src="media/image2.png" style="width:5.75833in;height:0.825in" alt="d02ef6ef00a221b4062004bf8b5642a3" />

\# ② Device 0 → Host（D2H）：8MB/次，迭代100次 ascend-dmi --bw -t d2h -d 0 -s 8388608 --et 100<img src="media/image3.png" style="width:5.76736in;height:0.85069in" alt="8ce9743408486e0e69d19d48798dbb88" />

3、步长模式测试（自动遍历不同数据大小）工具会从最小数据量（如 1KB）到最大（如 8MB）按步长递增测试，迭代 100 次 / 每个数据量，对比不同数据大小的传输性能。

\# ① Host → Device 0（H2D）：步长模式，迭代100次/每个数据量 ascend-dmi --bw -t h2d -d 0 --et 100<img src="media/image4.png" style="width:5.7625in;height:2.53681in" alt="bea15ff78259d88274d8579e1fcb487f" />

\# ② Device 0 → Host（D2H）：步长模式，迭代100次/每个数据量 ascend-dmi --bw -t d2h -d 0 --et 100<img src="media/image5.png" style="width:5.76458in;height:2.66042in" alt="874cdfcfba333c259dd3ddfb708cb004" />

**H2D 实测峰值带宽 7.18 GB/s**，在标准区间 6.5~7.5 GB/s 内，性能正常。

> **D2H 实测峰值带宽 6.78 GB/s**，在标准区间 6.0~7.0 GB/s 内，性能正常。
>
> 小数据时延均 \< 15 us，交互链路正常。
>
> 本次 Ascend 310P3 数据传输性能 **全部符合规格，测试通过**。
