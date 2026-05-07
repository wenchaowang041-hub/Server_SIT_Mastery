安装驱动和固件：

1.  [昇腾文档-昇腾社区](https://www.hiascend.com/document)

    下载昇腾Atlas 200I SoC A1 核心板 25.2.0 NPU驱动和固件升级指导书 01(pdf)

2、<https://support.huawei.com/>

3、[Ascend 系列 昇腾计算 HDK 软件补丁下载](https://support.huawei.com/enterprise/zh/ascend-computing/ascend-hdk-pid-252764743/software/266821732?idAbsPath=fixnode01|23710424|251366513|254884019|261408772|252764743)

<img src="media/image1.png" style="width:5.75625in;height:3.3375in" alt="2b6b66e10f2681b5d04af4bfa057a535" />

4、下载310P对应的驱动和固件包

5、上传到os下执行安装命令

<img src="media/image2.png" style="width:5.76458in;height:2.00139in" alt="cda9a0590957a085b7df6e237d76b3b5" />

6、

安装success后

Reboot<img src="media/image3.png" style="width:5.76458in;height:0.79653in" alt="cc19527320306649f4ba1d782757a151" />

报错-8005

Uname -r确认现在内核版本

<img src="media/image4.png" style="width:5.76736in;height:0.96528in" alt="c57d1512ff443699f1d691270e5c5074" />

查看已安装的昇腾驱动版本确认驱动是否支持 6.6 内核

<img src="media/image5.png" style="width:5.76667in;height:1.64236in" alt="9fab4ef8febc262c7f55975f5346b294" />

发现内核版本不支持最新的、将 OpenEuler 24.09 的 6.6 内核降级到驱动兼容的 5.10 内核（OpenEuler 22.03 LTS 版本的内核）

降级系统内核（推荐，成本最低）

将 OpenEuler 24.09 的 6.6 内核降级到驱动兼容的 5.10 内核（OpenEuler 22.03 LTS 版本的内核），步骤如下：

安装兼容的 5.10 内核包：

\# 配置OpenEuler 22.03源（临时）cat \> /etc/yum.repos.d/oe2203.repo \<\< EOF

\[oe2203\]

name=OpenEuler 22.03 LTS

baseurl=https://repo.openeuler.org/openEuler-22.03-LTS/OS/x86_64/

enabled=1

gpgcheck=0

EOF

\# 安装5.10内核

yum install -y kernel-5.10.0-60.18.0.50.oe2203.x86_64 kernel-devel-5.10.0-60.18.0.50.oe2203.x86_64

安装完成后重启

<img src="media/image6.png" style="width:5.15625in;height:1.20833in" alt="073bc00d7df436d1bf26b8979b319542" />

设置 5.10 内核为默认启动项：

\# 查看内核启动项索引（5.10内核通常在0或1位置）

grubby --info=ALL \| grep -E "index\|kernel"

\# 设置默认启动项（假设5.10内核索引为0）

grubby --set-default-index=0

重启系统，验证内核版本：

reboot# 重启后执行uname -r \# 应输出5.10.0-60.18.0.50.oe2203.x86_64

<img src="media/image7.png" style="width:5.76319in;height:3.12569in" alt="ce33b2758a19bdb3a00febd4d5c031ff" />

重新加载昇腾驱动模块并验证：

运行

modprobe ascend_dcmi

npu-smi info

卸载原内核版本安装的驱动：

\# 执行昇腾驱动自带的卸载脚本

/usr/local/Ascend/driver/script/uninstall.sh

检查是否卸载干净

lsmod \| grep ascend

无输出就是ok

再次安装驱动

安装CANN套件：

1、[CANN下载-CANN安装-昇腾社区](https://www.hiascend.com/cann/download)

访问网址<https://www.hiascend.com/cann/download>

2、选择产品系列

<img src="media/image8.png" style="width:5.76806in;height:2.19653in" alt="217bdc8a260646b4064411b88bf3e107" />

3.  可以在OS下输入

    \[root@bogon ~\]# lspci -n -D \| grep -o '19e5:d\[0-9a-f\]\\3\\' \| head -n1 \| cut -d: -f2

    查看返回值输入到昇腾网页d500

    再次选择CPU架构、操作系统、安装方式

<img src="media/image9.png" style="width:5.75417in;height:2.63889in" alt="6820fe4dbb609c0474ac6598894c0f9e" />

4、根据流程安装

<img src="media/image10.png" style="width:5.76181in;height:3.38611in" alt="28452d21e5c85080fa448e6a3a574f3d" />

安装toolbox：

安装后配置环境变量：
