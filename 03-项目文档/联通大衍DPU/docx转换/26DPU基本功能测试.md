DPU基本功能测试

1、测试DPU是否具备独立管理电源状态能力，Host服务器上电未开机时，查看DPU工作状态<img src="media/image1.png" style="width:5.75347in;height:2.76042in" alt="c1aec3fc49f3fb98c4293f090754d2b3" />PASS

2、查看DPU的电源及健康指示灯的状态，以及各个网口LED的状态是否正常，Host服务器上电，等待10分钟，查看DPU的电源及健康指示灯的状态。将DPU的所有网口连接到交换机，查看各个网口LED的状态。

<img src="media/image2.jpeg" style="width:3.92847in;height:2.94514in" alt="121c1a193b8f2dde9eca6ee24f92bab2" />

3.  查看DPU启动过程是否可以通过ipmi命令激活DPU SOL，Host服务器上电并开机，进入BIOS Setup配置Host BMC IP，带外通过ipmi命令激活DPU SOL，查看DPU启动过程。再核一下

    <img src="media/image3.png" style="width:5.76319in;height:0.36111in" alt="d40083e03818e5fa13a3e7267a15271a" /><img src="media/image4.png" style="width:5.75903in;height:2.44236in" alt="37327b14812255cea6131e53ed5a6d62" />

<img src="media/image5.png" style="width:5.75694in;height:0.47847in" alt="a69ff6cf338e9fca0a2d8e0f5bd1f447" />

4、通过连接DPU串口查看DPU启动过程是否正常，测试笔记本连接DPU串口，查看DPU启动过程。

连接DPU串口DPU启动正常

5、查看电源键操作对DPU BMC和系统状态的影响，Host服务器上电，等待DPU进入系统，长按电源键3s以上，查看DPU BMC状态；长按电源键9s以上，查看DPU系统状态；短按电源键，查看DPU系统状态。

<img src="media/image6.jpeg" style="width:4.55069in;height:2.56042in" alt="c4c0ec209091725067e39d1c479bbfcd" />

6、验证通过U盘或PXE安装DPU OS是否成功，将OS镜像做成可启动U盘，可启动U盘连接到DPU USB接口，安装DPU OS，将DPU的管理网口连接到PXE服务器，通过PXE安装DPU OS。

记录

<img src="media/image7.png" style="width:5.76806in;height:3.34931in" alt="ce4abea40ebf10e1e4f477c1308532d4" /><img src="media/image8.png" style="width:5.76597in;height:3.375in" alt="b3497ff785786d0ba0f368744d6f5f38" /><img src="media/image9.png" style="width:5.76389in;height:4.52917in" alt="653967e4db2f8981cff8d82a358ba379" /><img src="media/image10.png" style="width:5.76389in;height:4.52917in" alt="afe3deb29b54aad8a39baf0db6984a58" /><img src="media/image11.png" style="width:5.76389in;height:4.52917in" alt="cf5fe22b6d4f44b70d366188c7ad411d" /><img src="media/image12.png" style="width:5.76319in;height:1.64306in" alt="19f0c240c658689a0d029b5b1a5e8632" /><img src="media/image13.png" style="width:5.76389in;height:4.52014in" alt="f7bf7f78092c18e98afda423c1c67657" />Pass

7、如DPU具有SCP，验证DPU SCP是否可以成功更新且版本显示正确，在DPU系统下或者带外通过命令升级DPU的SCP。

<img src="media/image14.png" style="width:5.76181in;height:1.45903in" alt="a427435c-56d5-475e-97da-56fee6a90453" />

8、验证DPU BMC是否可以成功更新且版本显示正确，在DPU系统下或者带外通过命令升级DPU的BMC。

<img src="media/image15.png" style="width:5.75833in;height:1.54931in" alt="12f04413-13ab-43fa-9635-abe913042483" />

9、验证DPU CPLD是否可以成功更新且版本显示正确，在DPU系统下或者带外通过命令升级DPU的CPLD

<img src="media/image16.png" style="width:5.75556in;height:1.20972in" alt="1652101d-7a53-46b1-ac5c-0a4312e87fb5" />

10、如DPU具有IMU，验证DPU IMU是否可以成功更新且版本显示正确，在DPU系统下或者带外通过命令升级DPU的IMU

<img src="media/image17.png" style="width:5.7625in;height:1.23056in" alt="b2f9fa95-5022-403d-8af5-de2510c71ee6" />

11、验证DPU FRU信息是否显示正常，登录Host服务器BMC web界面，查看DPU FRU信息。带外通过ipmi命令查看DPU FRU信息。

<img src="media/image18.png" style="width:5.76389in;height:3.24097in" alt="bc03d0c3-4165-493f-808e-546a76ca735b" />

<img src="media/image19.png" style="width:4.66111in;height:2.41597in" alt="f9a0617b-e3f1-41fa-9b70-f6df47e46701" />

（12）验证DPU相关温度及功耗是否正常，登录Host服务器BMC web界面，查看DPU相关温度及功耗。带外通过ipmi命令读取DPU相关温度及功耗。

<img src="media/image20.png" style="width:5.76181in;height:1.65972in" alt="e6d8acbe-cb87-4894-8bb5-dad167c8a4ad" />

<img src="media/image21.png" style="width:5.76319in;height:0.42847in" alt="bc0dfc48-3c38-44a4-8f33-b027f32765cf" />

<img src="media/image22.png" style="width:5.75833in;height:3.02569in" alt="0867a1aa-a670-4d35-9544-2f1b03a607d5" />

（13）验证Host服务器是否可以正确识别到DPU设备，Host服务器开机进入Linux系统，查看DPU PCI设备信息。可执行lspci \|grep -i virtio查看

<img src="media/image23.png" style="width:5.75833in;height:1.32917in" alt="384e662e-b426-421d-9d0a-0b3b3f462fb8" />

（14）验证DPU OS是否可以正确识别到DPU CPU、内存、磁盘、网口信息，进入DPU OS，查看DPU信息。ip a（查看DPU网口信息），lscpu（查看DPU CPU信息），dmidecode -t memory（查看DPU内存信息），smartctl -a /dev/sda（查看DPU磁盘信息）。

<img src="media/image24.png" style="width:2.83056in;height:1.66319in" alt="a57597cd-1b3a-4c3d-b8da-239a85e789bb" /><img src="media/image25.png" style="width:2.82083in;height:1.60556in" alt="713a4d54-1bd8-4167-a51e-474b6eaf0257" />

<img src="media/image26.png" style="width:3.43889in;height:6.70417in" alt="74f2b3c2-7f2c-48d9-be36-73ebc15080d8" />

<img src="media/image27.png" style="width:5.73403in;height:8.49097in" alt="c68df231-175d-4ac1-8498-463ee29fc392" />

（15）验证DPU的两个管理网口是否可以成功配置成Bond1且功能正常，进入DPU的OS，将两个管理网口配置成Bond1。

<img src="media/image28.png" style="width:2.40556in;height:1.55833in" alt="d88068132f0e7ac64a1af30b2b050f91" /><img src="media/image29.png" style="width:2.57569in;height:1.57986in" alt="eb8bbb7592d4c9dccd79b7e5f9a3da57" /><img src="media/image30.png" style="width:2.56806in;height:0.89306in" alt="fbfaef4ef94804b27f966c7f45bdf21b" /><img src="media/image31.png" style="width:5.7625in;height:0.50417in" alt="f65348937bc0838d81f336393fa1f3b0" />PASS

（16）验证DPU的四个数据网口是否可以两两配置成Bond4且功能正常，进入DPU的OS，将四个业务网口两两配置成Bond4。

<img src="media/image32.png" style="width:5.76389in;height:1.60972in" alt="864bcf045c8fd250aeef67c499ab3230" /><img src="media/image33.png" style="width:2.66319in;height:1.525in" alt="f7ec72fc6b08f741e06d15076215bf24" /><img src="media/image34.png" style="width:2.86389in;height:1.55903in" alt="befc7218480ff61235f56be957d1bfe7" /><img src="media/image35.png" style="width:5.76806in;height:0.61528in" alt="b173621b87a8f24f24cb7ce5133ad08c" />

PASS

（17）在服务器上电关机状态下，通过bmc查看风扇以及散热系统。

<img src="media/image36.png" style="width:2.5625in;height:1.68264in" alt="cd23bb4e-9d30-4a08-ad88-0dce6ac2a2a0" /><img src="media/image37.png" style="width:2.97986in;height:1.65694in" alt="85e8dca7-f15b-4d30-99b4-efd8b92f3dd7" />

<img src="media/image38.png" style="width:5.75833in;height:3.61736in" alt="e88a5874-6465-4c88-8a71-e36323bf96b9" />PASS
