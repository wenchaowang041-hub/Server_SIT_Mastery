一、2026.03 架构格局一句话总结
Hopper (H100/H200)：存量主力，TMA 异步拷贝奠定计算 / 访存解耦基础。
Blackwell (B200/GB200)：当前绝对核心，细粒度调度 + 稀疏化执行 + 巨型 L2 + 第五代 TMA。
Rubin (2026 下半年)：即将登场，HBM4 + 动态 Warp 调度 + FP4 原生 + Vera-CPU 异构。
Feynman (2028)：远期规划，量子混合计算方向。
二、Blackwell SM 与调度核心（必背）
1. SM 定位
微型数据工厂：计算、稀疏调度、内存搬运全硬件化。
2. 关键硬件
第五代 Tensor Core：支持动态稀疏调度，自动跳过零值，提升有效吞吐量。
巨型 L2 Cache：大幅降低 HBM 访问，减少调度停顿。
第五代 TMA：独立硬件单元，全局 ↔ 共享内存搬运，计算与通信完全重叠。
3. 线程调度机制
每个 SM：4 个 Warp 调度器
单周期：每个调度器可发射 1 条指令
支持 Dual-Issue 双发射（ALU + Load/Store）
SIMT 模型不变，但硬件分支栈更深，嵌套分支开销更低
cp.async 显式异步，让调度器把搬运与计算分到不同硬件单元
三、Rubin 架构前瞻（2026 下半年）
HBM4：带宽 ≥13TB/s，内存墙大幅缓解
Warp 调度：更激进的动态 Warp 调度，适配万亿参数大模型
原生 FP4：新增低精度指令与专用执行单元，可能出现高精度 / 低精度 Warp 分类调度
Vera CPU 深度集成：硬件级 CPU-GPU 任务调度，降低 kernel 启动开销
性能重心从 Occupancy 转向单 Warp 吞吐量 & 指令混合度
四、三代架构代码优化对比（极简版）
表格
优化维度	Hopper	Blackwell	Rubin（预判）
内存	手动 cp.async 预取	充分用 TMA，硬件自动张量加载	依赖 HBM4，少预取，重缓存命中
分支	严格避免 Warp 发散	利用稀疏化，允许结构化分支	FP4 分支注意数值稳定性
占用率	追求高 Occupancy	平衡占用率与寄存器，提升 ILP	占用率重要性下降，单 Warp 吞吐为王
指令编排	计算 / 访存分离	ALU+TMA 混合，利用双发射	FP4/FP8 混合精度指令流优化
五、学习与查资料路径（2026 可用）
Blackwell 架构白皮书：NVIDIA Blackwell Architecture In-Depth
CUDA 12.x/ 13.x 文档：重点 cp.async / tma.load / PTX ISA
GTC 2025：Blackwell 性能优化专场、Jensen 主题演讲
Rubin 信息主要来自 GTC 2025 官宣与后续架构预览
六、最终核心结论
2026 年学 NVIDIA 调度：先吃透 Blackwell 的 TMA + 稀疏 Tensor Core + 细粒度 Warp 调度。
未来 Rubin 本质是：用更高带宽、更低精度、更动态调度，把 “算力密度” 推到新量级。
程序员从手动管内存 → 交给硬件自动调度 → 专注算法与精度混合编排。