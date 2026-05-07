# GPU 核心计算单元：SM 架构演进与昇腾 AI Core 对比

**文档定位：教学用详细填充版**  
**更新日期：2026-03-31**  
**本文范围：NVIDIA 各代 SM 横向对比 + 昇腾 Da Vinci AI Core 架构解析 + 跨体系对比框架**

---

## Part 1：为什么要做架构代际对比

很多人学 GPU 架构的方式是：背一张参数表。  
这种方式学到的东西，一旦下一代架构出来就全作废了。

我希望用另一种方式：

**通过每代架构"改了什么、为什么改、改完带来什么问题"，建立一个演进逻辑，而不是参数清单。**

这样，当我看到 Blackwell 的某个特性，能说出"这是解决 Hopper 上什么问题的延续"；  
当我看到昇腾 AI Core，能说出"这和 NVIDIA 解决的是相同问题，但选了不同路径"。

这才是真正的架构理解。

---

## Part 2：NVIDIA SM 架构演进横向对比

### 2.0 先建立阅读框架

看下面对比表时，需要理解几个维度的意义：

**为什么看"Warp Scheduler 数量"？**  
Warp Scheduler 越多，每个周期能发射的 Warp 就越多，隐藏访存延迟的能力越强。  
但它不能无限增加，受制于寄存器文件的分区数和指令分发带宽。

**为什么看"Register File 大小"？**  
寄存器是 SM 上的稀缺资源，直接决定能驻留多少 Warp，进而决定 Occupancy 上限。  
Register File 越大，驻留能力越强，但片上面积代价也越大。

**为什么看"Shared Memory 大小"？**  
Shared Memory 是 Block 内线程之间共享的片上快速存储，直接影响数据复用效率。  
但它是 SM 级别的有限资源，每个 Block 用得越多，SM 能同时驻留的 Block 就越少。

**为什么看"Tensor Core 代数"？**  
每代 Tensor Core 支持的精度类型、矩阵尺寸、吞吐量都不同。  
精度越低，吞吐越高；支持的格式越多，适用场景越广。

---

### 2.1 七代 SM 核心参数对比总表

> 说明：以各代旗舰数据中心 GPU 的 SM 参数为准。  
> 消费级 GPU（如 GA102 vs GA100）同代之间结构相近但规模不同，理解时以数据中心版为主。

| 维度 | Kepler (GK110) 2012 | Maxwell (GM200) 2014 | Pascal (GP100) 2016 | Volta (GV100) 2017 | Turing (TU102) 2018 | Ampere (GA100) 2020 | Hopper (GH100) 2022 | Blackwell (GB100) 2024 |
|---|---|---|---|---|---|---|---|---|
| **FP32 CUDA Cores/SM** | 192 | 128 | 64 | 64 | 64 | 64 | 128 | 128 |
| **FP64 CUDA Cores/SM** | 64 | 4（弱） | 32 | 32 | 2（弱） | 32 | 64 | 64 |
| **INT32 Cores/SM** | — | — | — | 64（独立） | 64（独立） | 64 | 64 | 64 |
| **Warp Schedulers/SM** | 4 | 4 | 2 | 4 | 4 | 4 | 4 | 4 |
| **Dispatch Units/SM** | 8 | 8 | 4 | 4 | 4 | 4 | 4 | 4 |
| **Tensor Core/SM** | 无 | 无 | 无 | 8（第1代） | 8（第2代） | 4（第3代） | 4（第4代） | 4（第5代） |
| **Register File** | 64K × 32bit | 64K × 32bit | 64K × 32bit | 64K × 32bit | 64K × 32bit | 64K × 32bit | 64K × 32bit | 64K × 32bit |
| **Max Shared Memory/SM** | 48KB | 96KB | 64KB | 96KB | 96KB | 164KB | 228KB | 228KB |
| **L1 Cache/SM** | 16~48KB | 独立 24KB | 24KB | 与SM共享最大128KB | 与SM共享最大128KB | 与SM共享最大192KB | 与SM共享最大256KB | 与SM共享最大256KB |
| **SFU/SM** | 32 | 32 | 16 | 16 | 16 | 16 | 16 | 16 |
| **Load/Store Units/SM** | 32 | 32 | 16 | 16 | 16 | 16 | 16 | 16 |
| **Max Warps/SM** | 64 | 64 | 64 | 64 | 32 | 64 | 64 | 64 |
| **Max Threads/SM** | 2048 | 2048 | 2048 | 2048 | 1024 | 2048 | 2048 | 2048 |
| **支持精度** | FP32/FP64 | FP32 | FP32/FP64/FP16 | FP32/FP64/FP16/INT8 | FP32/FP16/INT8/INT4 | FP64/TF32/BF16/FP16/INT8 稀疏 | FP64/TF32/BF16/FP16/FP8/INT8 | FP64/TF32/BF16/FP16/FP8/FP6/FP4 |
| **关键创新** | Hyper-Q | 更高能效 | NVLink/HBM | Tensor Core+独立线程调度 | RT Core | 稀疏加速/TF32/异步拷贝 | TMA/WGMMA/Thread Block Cluster | FP4/第五代TC |

---

### 2.2 Kepler（GK110，2012）：从混乱走向可编程

#### 背景
Kepler 之前的 Fermi 是 NVIDIA 真正进入通用 GPU 计算（GPGPU）时代的第一代，但能效和编程灵活性都有明显问题。  
Kepler 的核心任务是：**在不降低算力的前提下，大幅提升能效，并增强编程模型的灵活性。**

#### SM 结构（SMX）

Kepler 的 SM 被命名为 SMX，最显著的特征是：**一个 SM 里放了 192 个 CUDA Core**，数量远超后续所有架构。

但这里要注意一个陷阱：

> CUDA Core 数量多，不等于每周期执行效率高。

因为 Kepler 的 192 个 Core 实际上是分成 6 组的，每组 32 个，对应 4 个 Warp Scheduler。  
每个 Warp Scheduler 有 2 个 Dispatch Unit，理论上每周期可以双发射。  
但 192 个 CUDA Core 同时跑满，需要足够多的就绪 Warp 同时喂进来。

Kepler 的 Register File 也扩展到了 64K 个 32-bit 寄存器（前代 Fermi 是 32K），使得单 SM 可驻留 Warp 数翻倍，Occupancy 上限提升。

#### Kepler 的重要软件创新

**Hyper-Q（超并行队列）**  
Fermi 只有一条硬件工作队列，多个 CUDA 流其实是串行的。  
Kepler 引入了 32 条独立硬件工作队列，真正支持多 CUDA 流并行执行。  
这对 CPU-GPU 交互型任务意义重大，避免了因队列串行而导致的 GPU 空闲。

**Dynamic Parallelism（动态并行）**  
GPU Kernel 可以直接在 GPU 端启动子 Kernel，不需要返回 CPU 再调度。  
这为递归算法、自适应计算等不规则负载打开了大门。

#### 为什么后来 CUDA Core 数量反而降了

Kepler 的 192 CUDA Core per SM 设计带来了一个问题：  
**大量 CUDA Core 在控制流复杂的场景下根本喂不满，白占面积。**

Maxwell 后来"减"到 128，主要是提升了每个 CUDA Core 的实际利用率和能效，而不是算力倒退。  
这个"以质换量"的思路，贯穿了后续多代架构。

---

### 2.3 Maxwell（GM200，2014）：能效为王

#### 背景
Maxwell 的设计目标非常明确：**在同等面积和功耗下，做出比 Kepler 更高的实际吞吐。**  
它不追求单 SM CUDA Core 数量，而是追求更好的局部性和更高效的数据供给。

#### SM 结构（SMM）

Maxwell 将每 SM CUDA Core 从 192 减至 128，但做了两件关键事：

**1. 重新设计 Shared Memory**  
Maxwell 的 Shared Memory 从 Kepler 最大 48KB 增加到了 96KB（可配置），且从 L1 解耦合出来单独存在。  
L1 Cache 变成了独立的纹理缓存和通用缓存，不再与 Shared Memory 混用。  
这带来的好处是：Shared Memory 容量更确定，延迟更稳定，编程更可预期。

**2. 更好的调度和数据通路**  
Maxwell 的 Warp Scheduler 重新设计，每个 SM 被分成 4 个"Sub-Core"，每个 Sub-Core 有 32 CUDA Core + 独立的 Warp Scheduler + LD/ST 单元 + SFU。  
这种分区方式极大地提升了局部性和并发性，减少了跨区域的资源争用。

#### Maxwell 的能效突破

Maxwell 是历代 NVIDIA 架构中能效改善最显著的一代之一。  
在 28nm 工艺下，它的每瓦特算力比 Kepler 提升了约 2 倍，这在当时是相当惊人的成就。

这个成就主要来自：
- 更合理的 Sub-Core 分区设计，减少内部互联开销
- Shared Memory 与 L1 分离，减少了配置错误导致的低效
- 更精细的时钟门控和功率管理

#### Maxwell 的主要局限

Maxwell 几乎没有 FP64 算力（每 SM 只有 4 个 FP64 Core，是象征性的）。  
这说明 Maxwell 是为游戏和消费级通用计算设计的，不是科学计算路线。  
这也是 Pascal 为什么不从 Maxwell 直接继承，而是走了另一条更偏高性能计算的路线。

---

### 2.4 Pascal（GP100，2016）：科学计算 + HPC 的正式回归

#### 背景
Pascal 是一代非常重要的过渡架构。  
它同时面向两个市场：一是 Maxwell 延续的游戏/通用计算（GP10x 系列），二是 HPC/科学计算（GP100）。  
这里重点讲 GP100，因为它是 NVIDIA 进入数据中心 GPU 正规军的重要一步。

#### SM 结构（GP100 版本）

GP100 每 SM CUDA Core 变成了 64 FP32 + 32 FP64，且 Warp Scheduler 从 Kepler/Maxwell 的 4 个降为 2 个。

这看起来是"退步"，但实际逻辑是：

> 对于 HPC 场景，单个 Warp 的执行延迟不是主要问题，关键是每个时钟周期的 FLOP 数。  
> 减少 Warp Scheduler 数量，配合更大的 Register File（64K），让每个 Warp 能拿到更多寄存器，执行更复杂的数值计算。

**Pascal 的 Register File 是每 SM 256KB（64K × 4B），是史上最大的之一。**  
这对 HPC 的大量中间变量暂存非常重要。

#### Pascal 的两个关键创新

**1. NVLink（第1代）**  
GPU 之间直接通信带宽大幅提升，不再完全依赖 PCIe 总线。  
这使得多 GPU 训练从"慢慢等通信"变为"真正并行"。

**2. HBM2 内存**  
P100 是第一个用 HBM2 的数据中心 GPU。  
HBM2 相比 GDDR5 带宽提升了约 3 倍（720 GB/s vs ~250 GB/s），  
片上带宽终于不再是明显瓶颈。

**3. FP16 支持（原生）**  
Pascal 开始原生支持 FP16 计算，且 1 个 FP16 Core 每周期可以执行 2 个 FP16 操作（SIMD 打包）。  
这是 AI 推理加速的第一步，但还没有专用矩阵硬件。

---

### 2.5 Volta（GV100，2017）：AI 时代 SM 的分水岭

#### 为什么 Volta 是最重要的一代

在 Volta 之前，所有 GPU 的矩阵乘法都是用 CUDA Core 模拟的。  
一个 FP16 矩阵乘（MxNxK = 16x16x16），用 CUDA Core 需要数百条指令。  
Volta 做了一件事：**把矩阵乘加操作直接硬件化**，这就是第一代 Tensor Core。

这是 GPU 从"通用并行处理器"走向"AI 专用加速器"的真正起点。

#### SM 结构

Volta 的 SM 被分成了 4 个"Sub-Partition"，每个 Sub-Partition 包含：
- 16 个 FP32 CUDA Core
- 8 个 FP64 CUDA Core
- 16 个 INT32 Core
- 2 个 Tensor Core（第1代）
- 1 个 LD/ST Unit（8路）
- 1 个 SFU

**INT32 Core 的出现**  
Volta 首次引入了独立的 INT32 执行单元，可以在 FP32 计算进行时，同步执行地址计算等整型操作。  
这让 FP32 和 INT32 可以真正并发，不再互相阻塞。

#### 第一代 Tensor Core 的工作方式

第一代 Tensor Core 的基本操作是：
```
D = A × B + C
```
其中：
- A：4×4 FP16 矩阵
- B：4×4 FP16 矩阵  
- C：4×4 FP16 或 FP32 矩阵（累加器）
- D：4×4 FP16 或 FP32 矩阵

一个 Tensor Core 每个时钟周期可以完成 4×4×4 = 64 次 FP16 乘加操作（FMA）。

GV100 每 SM 有 8 个 Tensor Core，每时钟周期 SM 级 Tensor Core 吞吐：
```
8个TC × 64 FMA = 512 FP16 FMA/cycle/SM
```

对比 CUDA Core 方式（64 FP32 Core，每核每周期 1 FMA）：
```
64 × 1 = 64 FP32 FMA/cycle/SM
```

**矩阵路径比通用路径快约 8 倍（FP16 精度下）。**  
这就是为什么"走上 Tensor Core"如此重要。

#### 独立线程调度（Independent Thread Scheduling）

Volta 之前（Kepler/Maxwell/Pascal），同一个 Warp 的 32 个线程共享同一个 PC（程序计数器）。  
这意味着：即使你写了 `if/else`，Warp 内线程也只能按顺序先全跑 if 分支，再全跑 else 分支，不能真正"并发"。

Volta 给每个线程配备了独立的 PC 和调用栈：
- 不同线程可以在硬件层面真正并发执行不同控制流路径
- 收敛点（convergence）可以更灵活地设置
- 这解锁了更多算法的正确实现（如细粒度同步和生产者消费者模式）

**注意**：独立线程调度不代表分支发散消失了，它只是让控制流行为更正确，性能优化仍需要程序员关注。

---

### 2.6 Turing（TU102，2018）：加了 RT Core，Tensor Core 扩展精度

#### 核心变化

Turing 主要面向图形渲染市场，因此加入了 RT Core（实时光线追踪硬件单元）。  
在数据中心方向，Turing 的主要贡献是：

**第二代 Tensor Core 支持 INT8 和 INT4**  
这对 AI 推理意义重大：
- INT8 是很多推理场景的主流精度（模型量化后）
- INT4 进一步压缩，对延迟敏感的推理场景有价值

**精度扩展带来什么？**  
精度越低，每个 Tensor Core 单位时间能处理的数据量就越多，因为每个操作位宽更窄，可以打包更多操作。  
理论上：INT8 吞吐 ≈ 2× FP16 吞吐，INT4 吞吐 ≈ 4× FP16 吞吐（在同等时钟周期下）。

#### Max Threads/SM 的下降

Turing 消费级版本（TU102）每 SM 最大线程数从 2048 降到了 1024。  
这是因为 Turing 增加了 RT Core 占用面积，同时消费级对 Occupancy 的需求不如数据中心版那么严苛。  
（Turing 数据中心版 T4 则保留了更高 Occupancy 支持。）

---

### 2.7 Ampere（GA100，2020）：稀疏、TF32、异步拷贝——三大工程突破

#### 为什么 Ampere 是工程化程度最高的一代

Volta 第一个引入 Tensor Core，但当时工程师发现了几个问题：

1. 模型里很多矩阵其实是稀疏的（大量零值），但硬件按密集矩阵跑，浪费计算
2. FP32 精度很多训练任务其实不需要（用 FP16 就够），但直接用 FP16 有数值稳定性问题
3. 数据从全局内存搬到 Shared Memory，会阻塞当前 Warp，而搬运过程完全不能并行

Ampere 针对这三个问题做了系统性解决。

#### 结构化稀疏（2:4 Sparsity）

Ampere 在 Tensor Core 层面支持 2:4 结构化稀疏：  
**每 4 个权重中，至少有 2 个为零，Tensor Core 可以只处理非零值，吞吐量翻倍。**

```
稠密矩阵：[w0, w1, w2, w3] → 4次乘加
稀疏矩阵：[w0, 0, w2, 0]  → 只做 2次乘加，速度×2
```

代价是：模型需要在训练时或训练后进行稀疏化（剪枝），需要额外的工程投入。

#### TF32（TensorFloat-32）

TF32 是一种特殊格式：**指数位（8位）和 FP32 相同，尾数位（10位）和 FP16 相同。**

```
FP32：1位符号 + 8位指数 + 23位尾数 = 32bit
TF16：1位符号 + 8位指数 + 10位尾数 = 19bit（但对齐处理成32bit格式）
FP16：1位符号 + 5位指数 + 10位尾数 = 16bit
```

TF32 的价值在于：
- 数值范围和 FP32 完全相同（8位指数，不会溢出）
- 精度比 FP16 略差但可接受（10位尾数）
- 在 Tensor Core 上比 FP32 快约 10 倍

这使得很多原本必须用 FP32 做的训练任务，可以直接切到 TF32，几乎无痛加速。

#### 异步内存拷贝（memcpy_async / LDGSTS）

Ampere 之前，从全局内存到 Shared Memory 的数据搬运要经过：
```
全局内存 → L2 Cache → L1/Register File → Shared Memory
```
整个流程会暂时占用 Register，且当前 Warp 执行完 `ld.global` 后必须等数据到。

Ampere 引入了异步内存拷贝指令 `LDGSTS`：
```
全局内存 → L2 Cache → Shared Memory（直接写，绕过 Register）
```
更关键的是：这个操作是异步的，**当前线程不需要等它完成，可以继续执行其他计算**。

这实现了"数据搬运与计算重叠"（Memory-Compute Overlap），是性能提升的一大来源。

#### 第三代 Tensor Core

第三代 TC 每 SM 变成了 4 个（从 Volta/Turing 的 8 个减少），但每个 TC 能力大幅增强：
- 支持 FP64（Tensor Core 级别，不再只是 CUDA Core 级别）
- 支持 BF16（脑浮点，Google TPU 用的格式，对训练更友好）
- 支持结构化稀疏

最大共享内存也从 Volta 的 96KB 增加到了 164KB，给 Tensor Core 的数据预取留了更大空间。

---

### 2.8 Hopper（GH100，2022）：Transformer 时代的 SM 重构

#### 背景：Transformer 带来的挑战

从 BERT 到 GPT 系列，Transformer 模型的矩阵操作规模越来越大，呈现出几个新特点：

1. **矩阵越来越大**：单个矩阵乘需要跨越多个 Warp 才能充分利用 TC
2. **Attention 机制需要特殊访存模式**：FlashAttention 这类算法需要复杂的数据分块和异步移动
3. **FP8 成为训练主流精度**：进一步压缩精度，提升吞吐

Hopper 是第一个真正为 Transformer 大模型设计的 GPU 架构。

#### Thread Block Cluster（线程块集群）

Hopper 在线程层级里加了一层新的中间层：

```
Hopper 之前：Grid → Block → Warp → Thread
Hopper 之后：Grid → Cluster → Block → Warp → Thread
```

**Cluster** 是什么？  
它是一组可以共同访问彼此 Shared Memory 的 Block，通过 Distributed Shared Memory (DSMEM) 实现：
- Cluster 内 Block 的 Shared Memory 可以互相直接访问（低延迟，不走全局内存）
- Cluster 整体被调度到同一 GPC（图形处理集群），保证物理相邻

这解决了什么问题？  
**大矩阵操作时，数据分块后可以在 Cluster 内 Block 之间直接传递，无需经过全局内存中转。**

#### TMA（Tensor Memory Accelerator）

TMA 是 Hopper 最重要的硬件创新之一。  
它是 SM 内的一个**独立的专用数据搬运引擎**，专门负责多维张量数据从全局内存到 Shared Memory 的搬运。

与 Ampere 的 `memcpy_async` 相比，TMA 的升级在于：

| 对比维度 | Ampere memcpy_async | Hopper TMA |
|---|---|---|
| 发起方式 | 线程显式发起 | 一条 TMA 指令发起 |
| 多维数组 | 需要手动计算地址 | 硬件直接支持多维步长 |
| 数据格式 | 字节级 | 张量格式（含 swizzle、转置等） |
| CPU 线程占用 | 需要至少 1 个 warp 在发送 | 一个线程发起后可直接干别的 |
| Warp Group 协作 | 无 | 可以跨 Warp 协调 |

简单说：TMA 把"帮 Tensor Core 搬数据"这件事从程序员手里接走，变成专用硬件自动完成。  
**TMA 是 Hopper SM 内的第二个"引擎"，与 Tensor Core 并列。**

#### WGMMA（Warp Group Matrix Multiply Accumulate）

传统的 Tensor Core 指令（WMMA/MMA）以单个 Warp 为单位，操作 16×16 的矩阵块。  
Hopper 引入了 WGMMA，允许 4 个 Warp 组成一个 Warp Group 协同执行：

```
传统 MMA：1 Warp × 16×16×K = 小块矩阵
WGMMA：  4 Warp × 64×16×K 或更大 = 大块矩阵
```

更大的矩阵块意味着：
- 更高的 Tensor Core 利用率（减少边角浪费）
- 更好地配合 TMA 搬运的数据块尺寸
- 流水线中 Compute 与 Memory 阶段更好地对齐

#### FP8 支持（E4M3 和 E5M2）

Hopper 引入了两种 FP8 格式：
- **E4M3**：4位指数 + 3位尾数，精度较高，用于前向计算
- **E5M2**：5位指数 + 2位尾数，范围较大，用于梯度计算

FP8 相比 FP16 吞吐翻倍，是 Hopper 大模型训练的关键武器。  
配合"Transformer Engine"（自动在 FP8/FP16 之间切换），实现精度和性能的动态平衡。

#### Hopper SM 的 Shared Memory 扩展：228KB

Hopper 把每 SM 最大 Shared Memory 提升到了 228KB（Ampere 是 164KB）。  
这是为了配合 TMA 的大块搬运：如果 Shared Memory 太小，TMA 搬来的大矩阵块根本放不下，反而得分片搬运，失去效果。

---

### 2.9 Blackwell（GB100/GB200，2024）：FP4 + 双芯片互联

#### 第五代 Tensor Core 与 FP4

Blackwell 最受关注的特性是 **FP4（E2M1 格式）** 支持：

```
FP4：1位符号 + 2位指数 + 1位尾数
```

FP4 的精度极低，每个数只能表示约 16 个不同的值，但正因如此：
- 存储空间是 FP16 的 1/4
- 每次 Tensor Core 操作能打包处理的数是 FP16 的 4 倍
- 对显存带宽的需求大幅降低

FP4 主要用于大模型推理（而非训练），特别适合 LLM 部署场景。

**第五代 Tensor Core 的 FP4 吞吐是 Hopper 第四代 TC FP8 的 2 倍。**

#### 双芯片架构（Dual-die）

GB100 实际上是两个 GPU Die 通过高密度 Die-to-Die 互联（NV-HBI，高带宽互联）组合在一起，共同呈现为一块 GPU。

这带来了：
- 更大的总算力（两颗 Die 合并）
- 更大的显存容量（两套 HBM3e）
- NVLink-C2C 作为 Die 间互联，带宽超过 PCIe

代价是：需要软件栈（CUDA/cuBLAS/NCCL）感知双芯片拓扑，才能真正用满。

#### NV-FP4 与数据流整合

Blackwell 还引入了专门的解压缩引擎（Decompression Engine），可以直接从 NVLink 或 PCIe 接收压缩数据并解压，减少显存带宽压力。

这一系列设计说明：**Blackwell 已经不再是"算力数字游戏"，而是一个端到端的大模型推理基础设施。**

---

### 2.10 SM 演进的四条主线（教学总结）

通过上面 7 代的分析，可以归纳出 NVIDIA SM 演进的四条清晰主线：

#### 主线一：计算单元从通用到专用

```
Kepler/Maxwell：CUDA Core 做一切
Pascal：CUDA Core + 原生 FP16
Volta：CUDA Core + 第一代 Tensor Core（矩阵硬件化）
Turing：加入 RT Core（图形光追硬件化）
Ampere：Tensor Core 加入稀疏 + 更多精度
Hopper：Tensor Core + TMA（数据搬运硬件化）
Blackwell：Tensor Core + FP4 + 解压引擎（推理系统化）
```

**趋势：越来越多的操作从"软件用 CUDA Core 模拟"变为"专用硬件直接执行"。**

#### 主线二：支持精度从高精度走向低精度

```
Kepler/Maxwell：FP32 为主
Pascal：FP16 出现
Volta：FP16/FP32 Tensor Core
Turing：INT8/INT4 推理精度
Ampere：TF32/BF16 训练精度
Hopper：FP8 训练精度
Blackwell：FP4/FP6 推理精度
```

**趋势：精度下降是为了在可接受精度损失前提下，最大化单位功耗的吞吐量。**

#### 主线三：内存访问从阻塞到异步

```
Pascal 及之前：LD/ST 操作阻塞当前 Warp
Ampere：memcpy_async（线程手动发起异步拷贝）
Hopper：TMA（专用引擎，完全异步，Warp 不感知）
```

**趋势：把"等数据"这件事从线程中解耦，让线程专注于计算。**

#### 主线四：调度粒度从线程到系统级

```
Kepler：Hyper-Q（多流并行）
Volta：独立线程调度（Warp 内线程可独立）
Hopper：Thread Block Cluster（Block 间协作）
Blackwell：双芯片协同（Die 级别任务分发）
```

**趋势：硬件调度粒度越来越大，软件需要在更大尺度上组织计算。**

---

## Part 3：昇腾 Da Vinci 架构与 AI Core 解析

### 3.1 为什么不能用"国产版 SM"来理解 AI Core

一个常见的错误是：  
> 昇腾的 AI Core ≈ NVIDIA 的 SM，只是名字不同。

这个类比在入门时勉强能用，但会遮蔽关键差异。

真正的差异不在于名字，而在于**设计哲学**：

| 对比维度 | NVIDIA SM | 昇腾 AI Core |
|---|---|---|
| 核心假设 | 通用并行，任务由程序员用线程表达 | AI 专用，任务由编译器用算子图表达 |
| 执行粒度 | Warp（32 线程组） | 算子（Operator）级别的固定矩阵块 |
| 调度方式 | 硬件动态 Warp 调度器 | 编译期静态流水线调度 + 运行期任务队列 |
| 灵活性 | 高（任意控制流都能跑） | 低（但对神经网络算子极度优化） |
| 内存结构 | 统一 Shared Memory + Register File | 分层专用 Buffer（L0A/L0B/L0C/L1/UB） |
| 编程模型 | CUDA C++（线程视角） | CANN / TIK / DSL（算子视角） |

**AI Core 更像一条专门为矩阵流水线设计的生产线，而不是可以做任何事的通用工位。**

---

### 3.2 Da Vinci 架构的核心思想

Da Vinci 是华为昇腾 AI Core 的底层架构名称（从昇腾 310 到昇腾 910 系列都基于此）。

Da Vinci 的设计核心思想只有一句话：

> **把神经网络的计算流程（矩阵乘 + 激活 + 归一化 + 数据搬运）分解成专用单元，让它们形成无阻塞的流水线。**

这与 NVIDIA 的"通用 + 专用叠加"路线不同：  
NVIDIA 是在通用 SM 结构上不断加入专用单元（Tensor Core、TMA、RT Core）；  
昇腾是从一开始就按神经网络的操作分类，设计专用单元，再配以通用单元兜底。

---

### 3.3 AI Core 内部结构详解

一个完整的昇腾 AI Core 由以下部分组成：

```
┌─────────────────────────────────────────────────────────────────┐
│                         AI Core                                 │
│                                                                 │
│  ┌─────────────┐   ┌──────────────┐   ┌──────────────────────┐ │
│  │  Cube Unit  │   │ Vector Unit  │   │    Scalar Unit       │ │
│  │ (矩阵计算)  │   │  (向量计算)  │   │   (标量/控制/地址)   │ │
│  │  16×16 FP16 │   │ 128路 FP16   │   │   通用寄存器 + ALU   │ │
│  │   per cycle  │   │   per cycle  │   │                      │ │
│  └──────┬──────┘   └──────┬───────┘   └──────────────────────┘ │
│         │                 │                                      │
│  ┌──────▼──────────────────▼─────────────────────────────────┐  │
│  │                    片上存储层级                            │  │
│  │  L0A (64KB)  L0B (64KB)  L0C (256KB)  L1 (1MB)  UB(256KB)│  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              MTE（Memory Transfer Engine）                 │  │
│  │    MTE1（L1→L0A/B）  MTE2（Global→L1）  MTE3（L0C→UB）  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

下面逐一讲解每个模块。

---

### 3.4 Cube Unit（矩阵计算单元）

Cube Unit 是 AI Core 里相当于 NVIDIA Tensor Core 的单元，负责矩阵乘加操作。

**基本操作：**
```
C = A × B
```
- A：16×16 矩阵（从 L0A 读取）
- B：16×16 矩阵（从 L0B 读取）
- C：16×16 矩阵（写入 L0C）

一次操作：16 × 16 × 16 = 4096 次乘加（MACs）

**支持精度：**  
- FP16（主要训练精度）
- INT8（推理精度）
- BF16（昇腾 910B 及以后）
- FP32（精度较低吞吐，通过拆分完成）

**为什么这个设计固定了矩阵尺寸是 16×16？**  
因为 16×16 是一个在硬件面积、计算效率和数据搬运之间取得最佳平衡的尺寸：
- 太小：硬件每周期浪费时间在数据加载上，计算单元空转
- 太大：L0A/L0B 容量需要大幅扩展，面积代价指数上升

这和 NVIDIA Tensor Core 早期用 4×4×4 的思路是一样的，只是昇腾直接选了 16×16 的粒度。

---

### 3.5 Vector Unit（向量计算单元）

Vector Unit 负责逐元素的向量操作，对应 NVIDIA CUDA Core 的向量执行部分。

**主要负责的操作类型：**
- 激活函数（ReLU、GELU、Sigmoid 等）
- 归一化（LayerNorm、BatchNorm）
- 逐元素加减乘除
- 数据格式转换（FP16 ↔ FP32）
- Softmax（部分步骤）

**向量宽度：**  
Vector Unit 的执行宽度为 128 路，即每个时钟周期可以处理 128 个 FP16 数据的向量操作。

**为什么要有独立的 Vector Unit？**  
因为神经网络的计算不只是矩阵乘：
- 矩阵乘（Dense MMA）→ Cube Unit
- 激活、归一化、数据后处理 → Vector Unit

如果把激活函数也放 Cube Unit 里，会破坏 Cube Unit 的流水线节奏，得不偿失。  
分开成独立单元，可以并发执行：**矩阵乘正在跑的同时，上一批结果正在做激活函数。**

---

### 3.6 Scalar Unit（标量计算单元）

Scalar Unit 是 AI Core 里最"通用"的部分，更接近一个简化版的 CPU 核心。

**主要负责：**
- 循环控制（loop counter 更新）
- 地址计算（动态地址偏移）
- 条件跳转（if/else 控制流）
- 与 MTE 协调（发起数据搬运任务）

**为什么不把这些交给 Cube Unit 或 Vector Unit？**  
因为控制流操作是高度串行的，用并行度极高的 Cube/Vector Unit 来做只是浪费。  
Scalar Unit 的存在，让 AI Core 可以处理少量的控制逻辑，不必完全依赖编译期静态决策。

---

### 3.7 片上内存层级：L0A / L0B / L0C / L1 / UB

这是 AI Core 与 NVIDIA SM 差异最大的地方之一。  
NVIDIA 用统一的 Shared Memory + Register File 来支持任意访问，昇腾用分工明确的专用 Buffer 形成矩阵流水线。

```
全局内存（HBM/DDR）
    ↓ MTE2
L1 Buffer（1MB，临时数据仓库）
    ↓ MTE1                ↑ MTE3（L0C → UB）
L0A（64KB）  L0B（64KB）  L0C（256KB）  UB（256KB）
    ↘              ↙           ↑
         Cube Unit ────────────┘
                                UB ↔ Vector Unit
```

**L0A（左矩阵输入缓存）**  
专门存放 Cube Unit 输入矩阵 A，64KB，设计为高速、可流水读取。

**L0B（右矩阵输入缓存）**  
专门存放 Cube Unit 输入矩阵 B，64KB，同上。

**L0C（矩阵计算结果缓存）**  
Cube Unit 把计算结果写入 L0C，256KB，后续可被 Vector Unit 读取（做激活等操作）。

**L1 Buffer**  
相当于工厂的中转货仓，1MB，MTE2 把全局内存数据搬到这里，再由 MTE1 分发到 L0A/L0B。

**UB（Unified Buffer，向量单元本地缓存）**  
Vector Unit 的本地工作区，256KB，存放激活、归一化等中间结果。

**这套多级 Buffer 结构的核心价值：**  
让 Cube Unit 在做矩阵乘的同时，MTE2 可以在后台继续从全局内存搬下一批数据到 L1，  
MTE1 再从 L1 搬到 L0A/L0B，形成三级流水线，让 Cube Unit 几乎没有等待数据的时间。

---

### 3.8 MTE（Memory Transfer Engine）：数据搬运是第一公民

MTE 是 AI Core 里的三个独立数据搬运引擎，各司其职：

| MTE | 负责路径 | 作用 |
|---|---|---|
| MTE1 | L1 → L0A / L0B | 把已经在 L1 的数据分发给矩阵计算单元 |
| MTE2 | 全局内存（HBM）→ L1 | 从片外搬大块数据到片内暂存 |
| MTE3 | L0C → UB | 把矩阵结果送给向量单元做后处理 |

**三个 MTE 可以并发执行，与 Cube Unit 和 Vector Unit 同时工作。**

这是 Da Vinci 架构最精髓的设计：  
**计算单元永远有数据，数据通路永远不空闲。**

对应到 NVIDIA，这相当于 Hopper 的 TMA + WGMMA 流水线，但昇腾从第一代架构就以这种分工方式设计，更加彻底。

---

### 3.9 昇腾的软件栈：CANN 与 TIK

理解 AI Core 必须同时理解它的软件栈，否则只是记了一堆硬件模块名词。

#### CANN（Compute Architecture for Neural Networks）

CANN 是昇腾的核心计算框架，对标 NVIDIA 的 CUDA 生态。

```
用户层（PyTorch/MindSpore）
    ↓
AscendCL（算子调用接口，对标 cuDNN/cuBLAS）
    ↓
图引擎（GE，Graph Engine）：将算子图编译成设备执行序列
    ↓
TBE（Tensor Boost Engine）：算子库，预优化好的 Cube/Vector 操作
    ↓
AI Core 硬件执行
```

#### TIK（Tensor Iterator Kernel）

TIK 是昇腾的自定义算子开发工具，对标 NVIDIA 的 CUDA C++ + PTX。

如果你需要实现一个昇腾标准库里没有的算子，就用 TIK 写。  
TIK 是一个 Python DSL（领域专用语言），屏蔽了 MTE 指令和 Cube/Vector 调度细节，但仍然需要程序员管理 Buffer 的数据流。

**与 CUDA 编程的关键差异：**

| 对比维度 | CUDA C++ | TIK（昇腾） |
|---|---|---|
| 视角 | 线程视角（我这个线程做什么） | 算子视角（这个 Kernel 的数据怎么流） |
| 内存管理 | 程序员管理 Shared Memory | 程序员管理 L0/L1/UB 的数据流 |
| 调度方式 | 硬件 Warp Scheduler 动态调度 | 编译器决定执行顺序 + 硬件任务队列 |
| 调试工具 | Nsight Compute（Warp 级性能分析） | MindStudio（算子级流水线分析） |

---

### 3.10 昇腾各代 AI Core 关键参数对比

| 维度 | 昇腾 910（Da Vinci v1）2019 | 昇腾 910B 2023 | 昇腾 910C 2024-2025 |
|---|---|---|---|
| **每 AI Core Cube Unit** | 16×16 FP16，4096 MACs/cycle | 16×16 FP16，4096 MACs/cycle | 增强，FP8/BF16 支持更完整 |
| **每 AI Core Vector Unit** | 128路 FP16 | 128路 FP16，BF16 增强 | 进一步提升 |
| **L0A** | 64KB | 64KB | 64KB |
| **L0B** | 64KB | 64KB | 64KB |
| **L0C** | 256KB | 256KB | 256KB |
| **L1 Buffer** | 1MB | 1MB | 1MB+ |
| **UB** | 256KB | 256KB | 256KB+ |
| **AI Core 数量（芯片级）** | 32 | 60 | 更多（未完全公开） |
| **芯片总算力（FP16）** | 256 TFLOPS | ~576 TFLOPS | >800 TFLOPS（估算） |
| **HBM 带宽** | 1.2 TB/s | 1.6 TB/s | 2.0+ TB/s |
| **互联** | NVLink 类似的 HCCS | HCCS 增强 | HCCS 进一步增强 |
| **工艺节点** | TSMC 7nm | 7nm（优化版/备胎版） | 6nm-5nm 方向 |
| **主要精度改进** | FP16/INT8 | 加强 BF16 | FP8 支持更完整 |

---

## Part 4：NVIDIA SM vs 昇腾 AI Core 四层对比框架

### 4.1 第一层：核心计算单元对比

| 对比项 | NVIDIA SM | 昇腾 AI Core |
|---|---|---|
| **矩阵计算单元** | Tensor Core（代数逐步演进） | Cube Unit（16×16 固定模板） |
| **向量计算单元** | CUDA Core（通用FP32/INT32） | Vector Unit（128路专用向量） |
| **特殊函数** | SFU（sin/cos/exp 等） | Vector Unit（含部分特殊函数） |
| **控制/地址** | CUDA Core + Warp PC | Scalar Unit（独立） |
| **并发方式** | Warp 间时分复用 | Cube/Vector/MTE 流水线并发 |

**关键差异的本质：**  
NVIDIA 的 SM 是"通用 + 专用叠加"——CUDA Core 处理一切，Tensor Core 专门处理矩阵。  
昇腾的 AI Core 是"专用为主，通用兜底"——Cube Unit 专门处理矩阵，Vector Unit 专门处理向量，Scalar Unit 兜底控制流。  
两者都能跑神经网络，但能量分配比例和编程复杂度完全不同。

---

### 4.2 第二层：任务调度方式对比

| 对比项 | NVIDIA SM | 昇腾 AI Core |
|---|---|---|
| **调度粒度** | Warp（32 线程） | 算子任务（固定矩阵块） |
| **调度时机** | 运行时硬件动态决策 | 编译期静态确定 + 运行期按序执行 |
| **线程抽象** | 有（Grid/Block/Warp/Thread） | 极弱（TIK 里只有算子视图） |
| **灵活性** | 高（if/else/循环均支持） | 低（控制流需谨慎，主要走直线） |
| **延迟隐藏方式** | 多 Warp 切换（硬件调度） | MTE 流水掩盖搬运延迟（编译器安排） |

**核心判断：**  
NVIDIA 用"足够多的 Warp 待命"来隐藏访存延迟，这依赖动态调度器。  
昇腾用"搬运和计算在编译期就安排好流水线顺序"来隐藏延迟，这依赖编译器质量。

---

### 4.3 第三层：数据供给方式对比

| 对比项 | NVIDIA SM | 昇腾 AI Core |
|---|---|---|
| **片上存储结构** | Register File + Shared Memory（统一） | L0A/L0B/L0C/L1/UB（分层专用） |
| **数据搬运方式** | LD/ST 指令 + memcpy_async + TMA（Hopper） | MTE1/MTE2/MTE3（三引擎并发） |
| **数据路径** | 全局内存→L2→L1/Shared Memory→Register | 全局内存→L1→L0A/B→Cube Unit→L0C→UB |
| **搬运与计算** | Ampere 开始支持异步重叠，Hopper 由 TMA 完成 | 从第一代起三 MTE 与 Cube/Vector 并发 |
| **程序员控制** | 高（可精细控制数据布局） | 中（TIK 中需管理 Buffer 分配） |

**核心判断：**  
昇腾的数据通路从架构设计之初就是"流水线优先"，每一级 Buffer 的角色在硬件上是固定的。  
NVIDIA 是通用内存模型，灵活性更高，但代价是程序员必须主动优化数据布局。

---

### 4.4 第四层：软件栈成熟度对比

| 对比项 | NVIDIA CUDA 生态 | 昇腾 CANN 生态 |
|---|---|---|
| **编程语言** | CUDA C++（成熟，大量教程） | TIK Python DSL（较新，资料较少） |
| **算子库** | cuDNN、cuBLAS（业界标准） | CANN AscendCL（快速追赶中） |
| **框架支持** | PyTorch/TensorFlow/JAX 原生 | MindSpore 原生，PyTorch 需适配层 |
| **性能分析工具** | Nsight Compute/Nsight Systems | MindStudio（功能逐步完善） |
| **社区资料** | 海量（白皮书/顶会论文/开源代码） | 较少（文档在追赶，但仍有差距） |
| **工程人员储备** | 全球大量工程师 | 主要在国内，快速增长中 |

**关键判断：**  
硬件性能只是一方面，软件栈成熟度决定了硬件能否真正被用满。  
当前昇腾在软件生态上仍在追赶，但国内信创推动下发展速度很快。  
对于工程实践，理解软件栈的差异至少和理解硬件差异同样重要。

---

### 4.5 对比总结：同一问题，两种答案

两套架构解决的是完全相同的问题：  
**如何高效执行大规模矩阵运算为主的神经网络推理与训练？**

但选择了不同的系统性答案：

| 问题 | NVIDIA 的答案 | 昇腾的答案 |
|---|---|---|
| 矩阵乘太慢 | 加 Tensor Core，逐代增强 | 从一开始就设计 Cube Unit 专用硬件 |
| 数据搬运慢 | 异步拷贝→TMA，逐步解耦 | MTE 三引擎从第一代起并发 |
| 精度不够灵活 | FP16→TF32→BF16→FP8→FP4，逐代扩展 | FP16/INT8 先行，BF16/FP8 快速跟进 |
| 任务调度复杂 | 动态 Warp 调度 + Thread Block Cluster | 编译期静态流水线 + 任务队列 |
| 编程难度高 | CUDA C++（灵活但复杂） | TIK DSL（专用但更受限） |

两套路线各有优劣，并无绝对高下之分。  
但理解这种根本性的路线差异，才能避免用 NVIDIA 的思维框架去评价昇腾，或反过来。

---

## Part 5：用这套框架做实际工程判断

### 5.1 当我在 Kunpeng + Ascend 服务器上测试时，应该怎么想

基于我目前的工作环境（Atlas 300I，昇腾推理卡），在做性能测试或问题分析时：

**如果 NPU 利用率低，先想 Cube Unit 是否被喂饱**  
- 输入矩阵尺寸是否对齐 16×16 的整数倍？
- 算子是否走到了 Cube Unit 路径（还是退化成 Vector Unit 串行做）？

**如果推理延迟高，先想 MTE 是否形成了有效流水**  
- 数据是否在 L1 里预先放好了？
- 是否因为 L1 不够大导致反复从 HBM 搬运？

**如果发现特定算子慢，先看 CANN 版本和算子库支持**  
- 是否有对应的 TBE 预优化算子？
- 还是走了通用向量路径（性能差一个数量级）？

### 5.2 当我对比 NVIDIA 和昇腾跑同一模型时，应该看什么

**不能只看总 TFLOPS**  
因为两套架构的峰值算力都假设完美数据供给，实际利用率可能差很多。

**应该同时看：**
1. 实际 Cube/Tensor Core 利用率（不是理论峰值）
2. 显存带宽利用率（算力利用率高但带宽打满，说明 Memory Bound）
3. 算子级分解（哪个算子是瓶颈）
4. 软件栈版本（同一模型不同 CANN/CUDA 版本性能差异可以很大）

### 5.3 学习路径建议：先 NVIDIA，再迁移到昇腾

先学 NVIDIA SM + CUDA，原因：
- 公开资料多（白皮书、论文、工具链完善）
- 概念体系完整（Warp、Occupancy、Coalescing、Stall 分析等有成熟工具支撑）
- 能建立"高吞吐并行计算"的底层直觉

建立好底层直觉后，用四层对比框架迁移到昇腾：
1. 昇腾的 Cube Unit 解决什么问题？→ 对应 NVIDIA 的 Tensor Core
2. 昇腾的 MTE 解决什么问题？→ 对应 NVIDIA 的 TMA + memcpy_async
3. 昇腾的编译器调度解决什么问题？→ 对应 NVIDIA 的 Warp Scheduler + Thread Block Cluster
4. 昇腾的 CANN 生态现状？→ 对比 CUDA 生态看缺什么、强什么

这样迁移不是"背昇腾的名词"，而是真正理解两套体系的设计选择差异。

---

## Part 6：掌握标准——我怎么知道自己学明白了

### 6.1 SM 架构对比部分

能不看表格，清楚解释以下几个问题：

1. Kepler 为什么用了 192 个 CUDA Core 但 Maxwell 却降回 128 个，这不是退步吗？
2. Volta 引入 Tensor Core 之后，FP32 CUDA Core 的角色有什么变化？
3. Ampere 的稀疏加速需要什么前提条件，为什么不是所有模型都能用？
4. Hopper 的 TMA 和 Ampere 的 memcpy_async 本质区别是什么？
5. Blackwell 用 FP4 的前提条件是什么，它最适合哪类场景？

### 6.2 昇腾 AI Core 部分

能不看图，解释：

1. L0A、L0B、L0C 分别存什么数据？为什么要分三个 Buffer 而不是一个统一的？
2. MTE1、MTE2、MTE3 分别做什么？它们如何和 Cube Unit 并发？
3. Scalar Unit 为什么不能直接去掉，让编译器全静态决定？
4. 用 TIK 写算子和用 CUDA C++ 写 Kernel，最核心的思维转变是什么？

### 6.3 对比分析部分

面对一个实际问题"同一个 Transformer 模型，在 A100 和昇腾 910B 上吞吐差异很大，为什么"：

能不能从以下四个角度逐一分析可能的原因：
1. 矩阵计算单元利用率
2. 数据搬运效率
3. 软件栈和算子库支持程度
4. 调度粒度和控制流适配

如果能给出合理的分析框架（哪怕不是准确数字），就说明这套对比框架已经真正内化了。

---

## 附录：关键数字速查

### A.1 NVIDIA 各代 Tensor Core 吞吐（单 SM，单 GHz，FP16 为例）

| 架构 | TC 代数 | 每SM TC数 | 每TC FP16 FMA/cycle | 每SM理论FP16 FMA/GHz |
|---|---|---|---|---|
| Volta (GV100) | 第1代 | 8 | 64 | 512 |
| Turing (TU102) | 第2代 | 8 | 128（INT8翻倍） | 512 FP16 / 1024 INT8 |
| Ampere (GA100) | 第3代 | 4 | 512（含稀疏×2） | 2048 TF32 / 4096 FP16 稀疏 |
| Hopper (GH100) | 第4代 | 4 | 1024 FP8 | 4096 FP16 / 8192 FP8 |
| Blackwell (GB100) | 第5代 | 4 | 更高（含FP4） | FP4: Hopper FP8 的2倍 |

### A.2 昇腾 AI Core 关键尺寸记忆

| Buffer | 大小 | 对应单元 |
|---|---|---|
| L0A | 64KB | Cube Unit 左矩阵输入 |
| L0B | 64KB | Cube Unit 右矩阵输入 |
| L0C | 256KB | Cube Unit 结果累加 |
| L1 | 1MB | 全局内存数据中转 |
| UB | 256KB | Vector Unit 工作区 |

### A.3 Cube Unit 基础操作

```
输入：L0A[16×16×FP16] × L0B[16×16×FP16]
输出：L0C[16×16×FP32 or FP16]
吞吐：4096 FP16 MACs per cycle per Cube Unit
```

---

*文档版本：详细填充版 v1.0*  
*覆盖范围：NVIDIA Kepler→Blackwell SM 演进 + 昇腾 Da Vinci AI Core 架构解析 + 四层对比框架*  
*参考来源：NVIDIA 各代 GPU 白皮书、CUDA 文档、Da Vinci 架构公开材料、CANN 文档*
