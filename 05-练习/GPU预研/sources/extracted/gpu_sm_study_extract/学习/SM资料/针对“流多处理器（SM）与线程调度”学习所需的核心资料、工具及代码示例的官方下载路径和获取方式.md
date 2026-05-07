1. 核心文档与白皮书 (必读)
这些文档是理解硬件架构（SM 内部结构、调度器逻辑）的权威来源。
NVIDIA GPU 架构白皮书 (Whitepapers)
内容：包含 Hopper (H100), Blackwell (B200) 等最新架构的 SM 详细图解、寄存器大小、调度器数量、Tensor Core 规格。
下载路径：
访问 NVIDIA Technical Blog 或 NVIDIA Developer Docs。
搜索关键词："Hopper Architecture Whitepaper" 或 "Blackwell Architecture Whitepaper"。
直接链接示例（需根据年份更新）：https://developer.nvidia.com/blog/nvidia-hopper-architecture-in-depth/
重点章节：寻找 "Streaming Multiprocessor", "Thread Scheduling", "Memory Subsystem" 章节。
CUDA C++ Programming Guide
内容：官方编程指南，第 4 章 "Hardware Implementation" 详细描述了 Warp 调度、指令发射、延迟隐藏机制。
下载路径：
在线版：CUDA C++ Programming Guide
PDF 版：通常在安装 CUDA Toolkit 后，位于本地目录 C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\vXX.X\doc\pdf\ (Windows) 或 /usr/local/cuda/doc/pdf/ (Linux)。
PTX ISA Documentation (并行线程执行汇编语言指南)
内容：理解底层指令、谓词执行（处理分支发散的关键）、内存屏障。
下载路径：PTX ISA Documentation
2. 必备软件工具 (实战环境)
没有这些工具，无法进行性能分析和底层观察。
CUDA Toolkit (包含编译器 nvcc, 库文件)
作用：编译代码，生成 PTX/SASS 汇编。
下载路径：NVIDIA CUDA Toolkit Archive
建议：下载最新版（如 CUDA 12.x 或更高），以支持最新显卡特性。
Nsight Compute (ncu) - 核心分析工具
作用：最重要。用于查看 Warp 状态、占用率 (Occupancy)、停顿原因 (Stall Reasons)、指令发射效率。
下载路径：
通常随 CUDA Toolkit 一起安装。
独立下载安装包：Nsight Compute Downloads
注意：需要管理员权限运行，且需配合支持的 GPU 驱动。
Nsight Systems (nsys)
作用：系统级概览，查看 Kernel 在时间轴上的执行情况，CPU-GPU 交互。
下载路径：Nsight Systems Downloads
GPU Driver
作用：必须安装与 CUDA 版本匹配的最新版显卡驱动。
下载路径：NVIDIA Drivers
3. 代码示例与开源项目 (练手素材)
不要从零开始写所有代码，先阅读和优化现有代码。
NVIDIA CUDA Samples (官方示例库)
内容：包含大量优化过的 Kernel 示例，涵盖矩阵乘法、卷积、归约等，展示了如何避免分支发散、优化内存访问。
下载路径：
GitHub: NVIDIA/cuda-samples
本地：安装 CUDA Toolkit 后，通常在 C:\ProgramData\NVIDIA Corporation\CUDA Samples\vXX.X (Windows)。
推荐学习案例：
simpleMatrixMul (基础)
reduction (学习分支发散优化和共享内存使用)
bandwidthTest (学习内存吞吐量测试)
Cutlass (NVIDIA 高性能线性代数库)
内容：工业级优化的矩阵乘法实现，展示了极致的 Warp 调度和流水线设计（进阶必读）。
下载路径：NVIDIA/cutlass
学习点：查看其 kernel 目录下的 .cu 文件，学习如何通过模板元编程控制线程块划分和流水线阶段。
GPGPU-Sim (学术模拟器)
内容：如果你没有高端物理显卡，或者想修改调度算法本身（如修改轮转策略），这是唯一的途径。它是用 C++ 写的 GPU 模拟器。
下载路径：gpgpu-sim_distribution
用途：修改 shader.cc 或 scheduler.h 中的代码，模拟不同的调度策略对性能的影响。
4. 经典书籍 (系统化学习)
《Programming Massively Parallel Processors: A Hands-on Approach》
作者：David B. Kirk, Wen-mei W. Hwu
获取方式：
购买纸质书/电子书 (Amazon, Elsevier)。
部分高校图书馆可能有电子版。
这是该领域的“圣经”，强烈建议购买最新版（覆盖 Ampere/Hopper 架构）。
💡 快速开始检查清单
硬件检查：确认你有一张 NVIDIA GPU (建议 RTX 30/40 系列或专业卡)，并在终端输入 nvidia-smi 确认驱动正常。
环境搭建：
下载并安装 CUDA Toolkit。
验证安装：nvcc --version。
获取代码：
git clone https://github.com/NVIDIA/cuda-samples.git
编译第一个示例：
进入 cuda-samples/Samples/1_Utilities/bandwidthTest
运行 make (Linux) 或使用 Visual Studio 打开解决方案 (Windows)。
运行生成的可执行文件。
第一次分析：
运行 ncu ./bandwidthTest (可能需要 sudo)。
打开生成的 .ncu-rep 文件（使用 Nsight Compute GUI），查看 Scheduler Stats。