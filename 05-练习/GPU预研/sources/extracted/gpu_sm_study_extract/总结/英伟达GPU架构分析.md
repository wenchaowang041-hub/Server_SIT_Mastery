截至 2026 年 3 月，NVIDIA 的 GPU 架构正处于 Blackwell 全面普及 与 Rubin 即将登场 的关键转折点。理解这些架构对于掌握 SM（流多处理器）和线程调度至关重要，因为每一代架构都在调度策略、内存层次和计算单元上进行了重大革新。
以下是针对 2026 年视角 的 NVIDIA GPU 架构深度解析，重点聚焦于 SM 内部结构 和 线程调度机制 的演变。
1. 核心架构路线图 (2024-2028)
表格
架构代号	推出时间	代表产品	关键特性 (对调度影响)	状态 (2026.03)
Hopper	2022-2023	H100, H200	引入 TMA (Tensor Memory Accelerator) 异步拷贝，解耦计算与内存调度。	主流存量，逐步退居二线
Blackwell	2024-2025	B200, GB200, RTX 5090	双芯片封装，第五代 Tensor Core，支持 FP4。SM 内部调度更细粒度，强调稀疏化执行。	当前绝对主力，数据中心标配
Rubin	2026 (下半年)	R100, Vera-Rubin	HBM4 内存，第六代 NVLink。预计引入更激进的 动态 Warp 调度 以适配万亿参数模型。	即将发布 (GTC 2025 已官宣)
Feynman	2028 (规划)	-	量子混合计算探索，物理引擎优化。	规划阶段
2. Blackwell 架构 (当前核心)：SM 与调度的深度剖析
Blackwell学习“SM 与线程调度”的最佳实物模型。它在 Hopper 的基础上，进一步优化了 数据流 和 指令发射。
A. SM (Streaming Multiprocessor) 内部结构变化
在 Blackwell 中，一个 SM 不再仅仅是计算单元的集合，而是一个 微型数据工厂：
计算单元分区：
每个 SM 包含更多的 FP32/FP64 核心和 第四代/第五代 Tensor Core。
关键变化：Tensor Core 现在支持 稀疏化 (Sparsity) 的动态调度。如果检测到权重矩阵稀疏，调度器会自动跳过零值计算，相当于在同一时钟周期内“发射”了更多有效指令。
内存子系统升级：
L2 缓存巨大化：Blackwell 的 L2 缓存可达数百 MB，减少了 SM 访问 HBM 的频率，降低了调度器因内存延迟而停顿的概率。
第五代 Tensor Memory Accelerator (TMA)：这是一个独立的硬件单元，专门负责在 Global Memory 和 Shared Memory 之间搬运数据。它让 SM 的计算核心完全从“等待数据”中解放出来，实现了真正的计算 - 通信重叠。
B. 线程调度机制 (Scheduler) 的进化
Warp 调度器数量：每个 SM 通常配备 4 个 Warp 调度器 (具体数量视具体芯片配置而定，如 B200)。
指令发射 (Issue)：
每个调度器每个时钟周期可以尝试发射 1 条指令 给一个 Warp。
多发射 (Dual-Issue)：在某些特定指令组合下（如 ALU + Load/Store），Blackwell 允许同时发射两条指令，进一步压榨 ILP (指令级并行)。
分支处理：
继续采用 SIMT (单指令多线程) 模型。
改进：对于复杂的嵌套分支，Blackwell 的硬件栈更深，能更高效地保存/恢复分支状态，减少发散带来的开销。
异步执行模型：
通过 cp.async 指令，程序员可以显式告诉调度器：“这组线程去搬数据，那组线程继续算”。调度器会将这些操作分发到不同的执行单元（CUDA Core vs TMA），实现流水线满载。
3. Rubin 架构 (2026 未来)：前瞻展望
根据 GTC 2025 的信息，将于 2026 年下半年推出的 Rubin 架构将带来以下调度层面的变革：
HBM4 内存集成：
带宽提升至 13TB/s 以上。这意味着内存墙问题进一步缓解，Warp 因内存停顿 (Memory Stall) 的时间将显著减少。
调度影响：调度器将更少地切换到“等待型”Warp，更多地集中在计算密集型 Warp 上，对 Occupancy (占用率) 的敏感度可能降低，而对 指令混合度 的要求更高。
FP4 精度原生支持：
为了适应超大模型推理，Rubin 将原生支持 FP4 格式。
调度影响：调度器需要识别新的 FP4 指令集，并在专用的低精度单元上调度这些 Warp。这可能引入新的 Warp 类型分类 机制（例如：高精度 Warp 和低精度 Warp 可能被调度到不同的子核心）。
Vera CPU 异构集成：
Rubin 平台将深度集成定制的 Vera CPU。
调度影响：系统级调度将更加复杂，CPU 和 GPU 之间的任务划分可能由硬件自动管理，减少软件层面的 Kernel 启动开销。
4. 如何针对不同架构调整代码
表格
优化维度	Hopper (H100) 策略	Blackwell (B200/RTX 50) 策略	Rubin (未来) 预判
内存访问	必须手动使用 cp.async 预取	充分利用 TMA 单元，让硬件自动处理复杂的张量加载	依赖 HBM4 高带宽，减少手动预取，关注缓存命中率
分支控制	严格避免 Warp 发散	利用 稀疏化 特性，允许一定的结构化分支（如果能让 Tensor Core 跳过零值）	适应 FP4 低精度下的分支逻辑，注意数值稳定性
占用率 (Occupancy)	追求高占用率以隐藏延迟	平衡占用率与寄存器压力。Blackwell 寄存器文件巨大，适当增加每线程寄存器数以提升 ILP 可能更优	占用率重要性下降，单 Warp 吞吐量成为关键
指令混合	尽量分离计算和内存指令	混合发射：在计算指令间穿插 TMA 加载指令，利用双发射机制	针对 FP4/FP8 混合精度指令流进行编排
5. 文档
要深入研究 Blackwell 和 Rubin 的 SM 细节，请查阅以下 2025-2026 最新版 资料：
NVIDIA Blackwell Architecture Whitepaper
内容：详细的 SM 框图、Tensor Core 规格、TMA 工作原理。
搜索词："NVIDIA Blackwell Architecture In-Depth"
CUDA Toolkit 12.x / 13.x Documentation
重点：查看 PTX ISA 文档中关于 cp.async、tma.load 等新指令的描述。
GTC 2025 Sessions
黄仁勋的主题演讲以及技术分会场关于 "Blackwell Performance Optimization" 的视频，里面有大量关于调度器行为的实测数据。
总结：
学习 NVIDIA 架构的核心在于理解 Blackwell 如何通过专用硬件单元（TMA, Sparse Tensor Core）来辅助通用调度器，专注于算法逻辑。而即将到来的 Rubin 则将把这一趋势推向极致，通过 HBM4 和 FP4 重新定义“算力”的含义。