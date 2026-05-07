# BIOS配置

按快手定制化要求配置

BIOS 30.63.17版本已经将定制化项合入BIOS版本，按照BIOS默认配置即可

<img src="media/image1.png" style="width:5.76806in;height:2.91667in" />

# OS配置

快手要部署os时，会将透明大页配置为madvise

echo madvise \> /sys/kernel/mm/transparent_hugepage/enabled

<img src="media/image2.png" style="width:5.76806in;height:0.625in" />

# 安装speccpu2017

步骤1 创建Speccpu测试目录：

\#mkdir /home/spec2017

步骤2 挂载cpu2017软件(在POCkit speccpu2017/packages目录下)

\#mount cpu2017-1.1.8.iso /mnt

步骤3 进入挂载的/mnt路径，执行install.sh进行安装：

\#cd /mnt

\#./install.sh

如下所示，在提示输入安装路径时键入”spec2017”,在提示确认时键入”yes”进行确认：

linux-hyq4:/mnt \# ./install.sh

SPEC CPU2017 Installation

Top of the CPU2017 tree is '/mnt'

Enter the directory you wish to install to (e.g. /usr/cpu2017)

/spec2017

Installing FROM /mnt

Installing TO /spec2017

Is this correct? (Please enter 'yes' or 'no')

yes

The following toolset is expected to work on your platform. If the

automatically installed one does not work, please re-run install.sh and

…

省略

…

Testing the tools installation (this may take a minute)

...................................................................................................................................................................................................................................................................................................................-.......

Installation successful. Source the shrc or cshrc in

/spec2017

to set up your environment for the benchmark.

/////////完成安装

<img src="media/image3.png" style="width:5.76806in;height:7.08681in" />

# 运行speccpu2017

**上传配置文件至speccpu安装路径/home/spec2017/config下,附参考文件：**

**source shrc**

**runcpu -c kunpeng.cfg -n 1 --noreportable --copies=\`nproc --all\` intrate**

**runcpu -c kunpeng.cfg -n 1 --noreportable --copies=\`nproc --all\` fprate**

**<span class="mark">强力注意一定要把bios的时间调准确</span>**

**客户会跑3次，时间充足的话建议改成：runcpu -c kunpeng.cfg -n 3 --reportable --copies=\`nproc --all\` intrate**
