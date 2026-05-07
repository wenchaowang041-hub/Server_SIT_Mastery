联通大衍DPU测试报告

1.机器外观检测\
<img src="media/image1.jpeg" style="width:2.9in;height:1.94792in" alt="b34e88c5eaf53ba985fdbe42cf6b4749" /><img src="media/image2.jpeg" style="width:2.83889in;height:2.12917in" alt="3d2aee8f97fad5166275f96c6aa59755" />

<img src="media/image3.jpeg" style="width:2.72569in;height:2.16528in" alt="2f336c7e2b56c1c53137288989ef1753" />

PASS

2.CPU配置检测

<img src="media/image4.jpeg" style="width:3.23333in;height:2.11597in" alt="8641ad11c526197a87ff5d35e19ec201" />

<img src="media/image5.png" style="width:4.19514in;height:2.50972in" alt="a216a37a-07af-45b5-b410-39eb2073f8f8" />

PASS

3.DPU加速卡检测

（1）在操作系统下，使用命令查询DPU加速卡的厂家、型号、固件版本、CPU、内存、磁盘、网口信息

<img src="media/image6.png" style="width:5.34097in;height:2.65069in" alt="b214ae7f1766bd44b6d3d349318bed51" />

（2）被测DPU拍照，读取DPU卡信息，包括型号、接口类型、接口速率、接口数量等

<img src="media/image7.jpeg" style="width:5.76806in;height:4.32604in" alt="C:\Users\王文超\Documents\xwechat_files\wxid_87vwarpdr3u022_8b53\temp\RWTemp\2026-01\9e20f478899dc29eb19741386f9343c8\24a110209442af7bc46d217d90ecd0e5.jpg" />PASS

（3）通过命令方式，读取CPU信息，包括型号：主频、内核、缓存、数量等。登录DPU OS，执行以下指令进行查询

dmidecode -t Processor查看CPU型号、频率

<img src="media/image8.png" style="width:4.09722in;height:2.65486in" alt="a522025a-e83f-48f9-af4f-43678612cdf6" />

cpu虚拟核数：

<img src="media/image9.png" style="width:5.76597in;height:0.39306in" alt="b86c42de-131b-40d1-8dc0-ed0c905cd065" />

cpu socket数量：

<img src="media/image10.png" style="width:5.76181in;height:0.40625in" alt="b6ffff9e-56ca-4770-8ad8-672a1f25d13c" />

cpu L1d缓存：

<img src="media/image11.png" style="width:5.76597in;height:0.36736in" alt="879353ba-0147-4c9d-90eb-e532e5ce3b15" />

cpu L1i缓存：

<img src="media/image12.png" style="width:5.76458in;height:0.36806in" alt="b2fa82d6-bf36-41d8-8e8f-64d59e2ab384" />

cpu L2缓存：

<img src="media/image13.png" style="width:5.7625in;height:0.49097in" alt="597325b1-7fb8-474f-9e51-2f34fe7076f6" />

cpu L3缓存：

<img src="media/image14.png" style="width:5.76667in;height:0.48611in" alt="2b994b4a-25cd-4c10-9b29-a2bb02be0ed6" />

（4）通过命令方式，读取内存信息，包括槽位数、实配数、厂商、型号、频率、容量等。登录DPUOS，安装lshw，执行以下指令进行查询，执行lshw -c memory

<img src="media/image15.png" style="width:4.97431in;height:5.87917in" alt="4dda0071-67cb-4acc-8ef6-4876be1383c0" />

（5）通过命令方式，读取硬盘实配数、型号、容量、接口类型等

登录DPUOS，执行以下命令进行查询

实配数：lshw -c disk

<img src="media/image16.png" style="width:5.19722in;height:1.17014in" alt="ebd6a9af-e73d-40a1-aed3-3d47b972c363" />

型号、容量、接口类型：smartctl -i /dev/sda

<img src="media/image17.png" style="width:5.22917in;height:2.38819in" alt="76a81eea-3650-48fa-bd7f-9fc07d0c5e65" />

PASS

4.主板配置检测

（1）整机正面，俯视，后部正视等角度分别拍照，获取如下信息： 主板生产商信息，PCIE插槽类型和数量，USB，COM，VGA，BMC管理口，数量和位置，单板管理芯片（BMC）的芯片信息

<img src="media/image18.jpeg" style="width:2.67569in;height:1.50556in" alt="e01c4a0f53ada38bcb46bb810e121ed5" /><img src="media/image19.jpeg" style="width:2.76181in;height:1.55417in" alt="b4ae454e6cb55783fa060a2c048ad781" />

<img src="media/image20.jpeg" style="width:2.61042in;height:2.98264in" alt="11f3c4c32bd04a831d4af1c509fc90f2" />

（2）通过BIOS信息读取，可检测到BIOS版本信息、可检测到芯片组信息

<img src="media/image21.png" style="width:4.64583in;height:3.24722in" alt="b9382f20-7086-4585-a754-b091d13af549" />

（3）通过BMC 读取主板生产商信息、PCIE插槽类型和数量<img src="media/image22.png" style="width:5.75833in;height:2.44861in" alt="2ec6233ce8047396be4e38b0401d6035" />

<img src="media/image23.png" style="width:5.33681in;height:1.31528in" alt="d7a74beb84ccb6b084a054c945f706eb" />

（4）检查2U服务器是否配置Riser卡

<img src="media/image24.jpeg" style="width:3.8625in;height:2.17292in" alt="cfc385a9fbe9083c288925b5575695fe" />

PASS

5、设备状态指示灯显示功能测试

（1）接入电源，查看设备前面板电源指示灯并记录状态和颜色显示，查看所有电源模块是否具备指示灯并记录状态颜色

1\. 前面板电源指示灯状态：闪烁 ，颜色：橙色 ；状态：常亮 ，颜色：绿色

2\. 电源模块指示灯状态：闪烁 ，颜色：绿色 ；状态：常亮 ，颜色：绿色

闪烁

（2）摁下开机按钮，观察电源指示灯并记录状态和颜色显示及变化，查看并记录硬盘指示灯及网络指示灯颜色显示变化

3\. 硬盘指示灯状态：熄灭

4\. 网络状态指示灯状态：状态：常亮 ，颜色：绿色

（3）拔掉一个电源模块，查看健康状况指示灯变化

5\. 健康状态指示灯状态：正常 ，颜色：绿色常亮 ；状态：异常 ，颜色：红色闪烁

PASS，设备各部件具备状态指示灯并能针对相应状态变化显示

6、远程登录功能测试

<img src="media/image25.png" style="width:4.60486in;height:2.20625in" alt="8691f011-2fb0-44d0-807a-93423c761ef6" />

<img src="media/image26.png" style="width:4.72361in;height:2.24236in" alt="0e48fa47-f99e-4f43-b7ff-c314737acf0b" />

PASS，服务器BMC模块工作正常，网络管理端口接入及界面正常

7、远程控制功能测试

开机：

<img src="media/image27.png" style="width:4.60347in;height:2.20556in" />

重启：

<img src="media/image28.png" style="width:4.63958in;height:2.22292in" />

关机：

<img src="media/image29.png" style="width:4.73194in;height:2.09722in" alt="9b66e9ba-ca8b-42c3-a4b9-064059c9c725" />

<img src="media/image30.png" style="width:4.03681in;height:1.83611in" alt="4b7e6409-8dc7-4b3f-9256-7d52b35105fd" />

PASS，可以远程对被测试服务器进行开机、重启、关机操作

8、功率封顶功能测试

9、温度监控功能测试

<img src="media/image31.png" style="width:3.97431in;height:2.07361in" alt="ecc57ee6-8056-4455-869c-b14be4e1d15e" />

<img src="media/image32.png" style="width:4.67847in;height:1.62153in" alt="df6dccc6ae56f3464d4e8382d322350c" />

PASS，可以监控到被测试服务器温度信息（CPU温度，进风口温度等）

10、风扇监控功能测试

<img src="media/image33.png" style="width:5.76528in;height:2.13125in" alt="aaca9393-33d6-4c75-8498-3bd23cdff1e2" />

PASS，可以监控到被测试服务器风扇信息（转速或百分比）

管理界面风扇数量与机箱内风扇数量一致

11、故障告警测试

<img src="media/image34.png" style="width:5.65903in;height:2.57153in" alt="86c89f67-961d-4543-8954-2c8b0325d42e" /><img src="media/image35.png" style="width:5.66528in;height:2.88958in" alt="0f9a9092-5c14-4132-9256-3011e1ae7fa8" />

<img src="media/image36.png" style="width:5.01597in;height:1.70764in" alt="e37c6dfd-cde1-4958-80db-9b1216093770" />

<img src="media/image37.png" style="width:4.97639in;height:1.74722in" alt="833940f8-bb23-474c-8b20-375809c7496a" />

<img src="media/image38.png" style="width:5.17569in;height:1.95208in" alt="a5396843-d56a-4a95-b8b1-dc44db9b2412" />

<img src="media/image39.png" style="width:5.20764in;height:2.73819in" alt="5d7cb21e-a7c1-423c-97bf-c8b9c2583ea4" />

PASS

12. BIOS升级测试

<img src="media/image40.png" style="width:3.79514in;height:1.6875in" alt="291efff298517f8eee2b07a6aa17302f" /><img src="media/image41.png" style="width:4.42986in;height:1.49236in" alt="bc99affe321c7487796e203ff2aa6c52" />

<img src="media/image42.png" style="width:5.76042in;height:0.67431in" alt="e959c29a2da44ef4f41c268d562dcab9" />

<img src="media/image43.png" style="width:4.9in;height:3.26528in" alt="e3102ca698589d0078339cdfa8f36d4a" />

PASS

13、BMC升级测试

<img src="media/image44.png" style="width:3.28403in;height:1.9375in" alt="e3751970aaba0da3af6a05e54e68bc1a" /><img src="media/image45.png" style="width:5.47292in;height:1.90139in" alt="9ed3473148ef050ae927d32cea9ec1c3" />

PASS，BMC升级成功

14、VNC管理功能测试

<img src="media/image46.png" style="width:4.55556in;height:2.12917in" alt="d58be596-2572-4979-a884-4a72b7614bb0" />

<img src="media/image47.png" style="width:4.78681in;height:2.10347in" alt="946efdb4-592a-4897-bc36-038b43705282" />

PASS

15、服务器BMC读取DPU信息测试

<img src="media/image48.png" style="width:2.29514in;height:1.78819in" alt="b9a44a5d-434e-4788-90db-9942cd41003a" /><img src="media/image49.png" style="width:2.67292in;height:1.78819in" alt="1e4addbe-ac75-402f-9737-80b3a84fc2af" /><img src="media/image50.png" style="width:2.49306in;height:1.51597in" alt="3ce24b92-e250-4237-8931-c85b138afd25" /><img src="media/image51.png" style="width:2.93681in;height:1.72083in" alt="8342f73d-0386-484b-92db-2c623a7d4655" />

<img src="media/image52.png" style="width:4.28472in;height:2.07708in" alt="53cf5bd3-931c-428f-b51f-6348d8f1fe12" /><img src="media/image53.png" style="width:5.52639in;height:1.32292in" alt="aa18037d-f88d-484c-8faf-a88aa4c07f51" />

以上为dpu bmc查看的信息、以下为服务器bmc查看的信息

<img src="media/image54.png" style="width:5.76597in;height:2.975in" alt="654353d878f7572b17220e2077cdfead" /><img src="media/image55.png" style="width:5.75833in;height:0.82569in" alt="3ac2b84a1345be499366a4e3571c147c" />

<img src="media/image23.png" style="width:5.75278in;height:1.41806in" alt="d7a74beb84ccb6b084a054c945f706eb" /><img src="media/image56.png" style="width:5.76042in;height:2.94306in" alt="3d4a880ee36720581c69dd23cf9527a6" /><img src="media/image57.png" style="width:5.76736in;height:2.95in" alt="4c6a65c2d33c4d65a7b3e87a9732492a" />Ipmitool 查询IMU固件版本

<img src="media/image58.png" style="width:5.76042in;height:1.76319in" alt="7c760fbe-a238-4977-8b0b-996921b9d469" /><img src="media/image59.png" style="width:5.76319in;height:1.7375in" alt="af74f822-654f-4680-a5c4-18abfb6ae288" />

FAIL:BMC、CPLD、SCP和IMU固件版本；DPU内存容量；DPU硬盘容量无法查到

16、IPMI远程开关机及复位

远程开机

<img src="media/image60.png" style="width:5.75694in;height:0.32986in" alt="fb588043-d741-4823-b24e-67d282b294da" />

远程关机

<img src="media/image61.png" style="width:5.75347in;height:0.39167in" alt="e3047177-ae44-4a97-8aa2-f1b0f3ba92c0" />

远程复位

<img src="media/image62.png" style="width:5.75972in;height:0.31944in" alt="68337930-4c4b-42af-aadc-ab016509b622" />

电源状态

<img src="media/image63.png" style="width:5.75556in;height:0.32847in" alt="5cda565d-8fcf-475e-8ee4-f092927ad386" />

PASS，被测设备能够通过IPMI指令进行远程开机、关机、复位

17、通过 IPMI 获取整机功耗

<img src="media/image64.png" style="width:5.76042in;height:1.47153in" alt="f7ea54c3-2dc3-4ca2-8741-33a711210cdd" />

**PASS**

18、通过 IPMI 限制整机功耗上限

<img src="media/image65.png" style="width:5.76111in;height:0.17847in" alt="ecfb1936-8dd1-48cf-8372-c0f8b2f1b8f0" />

<img src="media/image66.png" style="width:5.75694in;height:0.10556in" alt="1210abf1-0cfb-4465-80e2-6081b3f5ed4c" />

未完成、链接功耗设备

19、查询服务器指定网卡（包括DPU及标卡）资源信息

20、配置服务器VNC服务开关

21、设置服务器启动设备

22、查询指定DPU加速卡资源信息

23、电源冗余和热插拔测试

<img src="media/image67.png" style="width:5.76389in;height:0.64236in" alt="608df31e-d901-4f90-8741-457b577a00f8" />

<img src="media/image68.png" style="width:5.75833in;height:0.76319in" alt="c19646697a809d8599d5a9ae4ea24fc8" /><img src="media/image69.png" style="width:5.76389in;height:0.92778in" alt="1a7bdea22be54f1b91e0712370e844e2" />

<img src="media/image70.jpeg" style="width:1.98819in;height:1.02708in" alt="b997ae8528ad2710a3a33f659aee2ca6" /><img src="media/image71.png" style="width:3.43264in;height:1.01736in" alt="98b4c7a8cde20e53e875462cf48329b0" />

<img src="media/image72.png" style="width:5.75278in;height:2.5375in" alt="2816e336-0778-41ec-bbba-42e16d992cc7" />

PASS

24、风扇冗余和热插拔检测

<img src="media/image73.png" style="width:5.75833in;height:1.01181in" alt="3d491a7ff5d3aeea449d3de96aca11f7" />

<img src="media/image74.png" style="width:5.75833in;height:1.09931in" alt="7520cdaf18c906bd885b4ecb079d4ba2" /><img src="media/image75.png" style="width:5.75833in;height:0.86458in" alt="6f31ee8ef030a738c7c288c13b1955f2" />

<img src="media/image76.jpeg" style="width:2.17639in;height:1.79722in" alt="8ac3cfff4cd57fb3aaac3a5061cbe783" /><img src="media/image77.png" style="width:3.475in;height:1.74236in" alt="eb92dcdc-7d1b-4b91-ab2f-c9fc5382125c" />

<img src="media/image78.png" style="width:5.75972in;height:1.70833in" alt="7c9a50c8dd936e362dd0a038595da86d" />

PASS

25、DPU基本功能测试

1、测试DPU是否具备独立管理电源状态能力，Host服务器上电未开机时，查看DPU工作状态

<img src="media/image79.png" style="width:4.52222in;height:2.54444in" alt="ca3daffe-8aef-49da-9809-578f50c0cf9f" />

2、查看DPU的电源及健康指示灯的状态，以及各个网口LED的状态是否正常，Host服务器上电，等待10分钟，查看DPU的电源及健康指示灯的状态。将DPU的所有网口连接到交换机，查看各个网口LED的状态。

<img src="media/image80.jpeg" style="width:3.92847in;height:2.94514in" alt="121c1a193b8f2dde9eca6ee24f92bab2" />

3、查看DPU启动过程是否可以通过ipmi命令激活DPU SOL，Host服务器上电并开机，进入BIOS Setup配置Host BMC IP，带外通过ipmi命令激活DPU SOL，查看DPU启动过程。

<img src="media/image81.png" style="width:5.17292in;height:2.53958in" alt="81cee610-c02b-4d51-b15f-494d0939d868" />

4、通过连接DPU串口查看DPU启动过程是否正常，测试笔记本连接DPU串口，查看DPU启动过程。

5、查看电源键操作对DPU BMC和系统状态的影响，Host服务器上电，等待DPU进入系统，长按电源键3s以上，查看DPU BMC状态；长按电源键9s以上，查看DPU系统状态；短按电源键，查看DPU系统状态。

<img src="media/image82.jpeg" style="width:4.55069in;height:2.56042in" alt="c4c0ec209091725067e39d1c479bbfcd" />

6、验证通过U盘或PXE安装DPU OS是否成功，将OS镜像做成可启动U盘，可启动U盘连接到DPU USB接口，安装DPU OS，将DPU的管理网口连接到PXE服务器，通过PXE安装DPU OS。

7、如DPU具有SCP，验证DPU SCP是否可以成功更新且版本显示正确，在DPU系统下或者带外通过命令升级DPU的SCP。

<img src="media/image83.png" style="width:5.76181in;height:1.45903in" alt="a427435c-56d5-475e-97da-56fee6a90453" />

8、验证DPU BMC是否可以成功更新且版本显示正确，在DPU系统下或者带外通过命令升级DPU的BMC。

<img src="media/image84.png" style="width:5.75833in;height:1.54931in" alt="12f04413-13ab-43fa-9635-abe913042483" />

9、验证DPU CPLD是否可以成功更新且版本显示正确，在DPU系统下或者带外通过命令升级DPU的CPLD

<img src="media/image85.png" style="width:5.75556in;height:1.20972in" alt="1652101d-7a53-46b1-ac5c-0a4312e87fb5" />

10、如DPU具有IMU，验证DPU IMU是否可以成功更新且版本显示正确，在DPU系统下或者带外通过命令升级DPU的IMU

<img src="media/image86.png" style="width:5.7625in;height:1.23056in" alt="b2f9fa95-5022-403d-8af5-de2510c71ee6" />

11、验证DPU FRU信息是否显示正常，登录Host服务器BMC web界面，查看DPU FRU信息。带外通过ipmi命令查看DPU FRU信息。

<img src="media/image87.png" style="width:5.76389in;height:3.24097in" alt="bc03d0c3-4165-493f-808e-546a76ca735b" />

<img src="media/image88.png" style="width:4.66111in;height:2.41597in" alt="f9a0617b-e3f1-41fa-9b70-f6df47e46701" />

（12）验证DPU相关温度及功耗是否正常，登录Host服务器BMC web界面，查看DPU相关温度及功耗。带外通过ipmi命令读取DPU相关温度及功耗。

<img src="media/image89.png" style="width:5.76181in;height:1.65972in" alt="e6d8acbe-cb87-4894-8bb5-dad167c8a4ad" />

<img src="media/image90.png" style="width:5.76319in;height:0.42847in" alt="bc0dfc48-3c38-44a4-8f33-b027f32765cf" />

<img src="media/image91.png" style="width:5.75833in;height:3.02569in" alt="0867a1aa-a670-4d35-9544-2f1b03a607d5" />

（13）验证Host服务器是否可以正确识别到DPU设备，Host服务器开机进入Linux系统，查看DPU PCI设备信息。可执行lspci \|grep -i virtio查看

<img src="media/image92.png" style="width:5.75833in;height:1.32917in" alt="384e662e-b426-421d-9d0a-0b3b3f462fb8" />

（14）验证DPU OS是否可以正确识别到DPU CPU、内存、磁盘、网口信息，进入DPU OS，查看DPU信息。ip a（查看DPU网口信息），lscpu（查看DPU CPU信息），dmidecode -t memory（查看DPU内存信息），smartctl -a /dev/sda（查看DPU磁盘信息）。

<img src="media/image93.png" style="width:2.83056in;height:1.66319in" alt="a57597cd-1b3a-4c3d-b8da-239a85e789bb" /><img src="media/image94.png" style="width:2.82083in;height:1.60556in" alt="713a4d54-1bd8-4167-a51e-474b6eaf0257" />

<img src="media/image95.png" style="width:3.43889in;height:6.70417in" alt="74f2b3c2-7f2c-48d9-be36-73ebc15080d8" />

<img src="media/image96.png" style="width:5.73403in;height:8.49097in" alt="c68df231-175d-4ac1-8498-463ee29fc392" />

（15）验证DPU的两个管理网口是否可以成功配置成Bond1且功能正常，进入DPU的OS，将两个管理网口配置成Bond1。

（16）验证DPU的四个数据网口是否可以两两配置成Bond4且功能正常，进入DPU的OS，将四个业务网口两两配置成Bond4。

（17）在服务器上电关机状态下，通过bmc查看风扇以及散热系统。

<img src="media/image97.png" style="width:5.7625in;height:3.78403in" alt="cd23bb4e-9d30-4a08-ad88-0dce6ac2a2a0" /><img src="media/image98.png" style="width:5.76806in;height:3.20625in" alt="85e8dca7-f15b-4d30-99b4-efd8b92f3dd7" />

<img src="media/image99.png" style="width:5.75833in;height:3.61736in" alt="e88a5874-6465-4c88-8a71-e36323bf96b9" />

26. DPU BMC

<!-- -->

1.  Host服务器上电未开机状态，DPU带外通过ipmi命令开、关、重启DPU。

<img src="media/image100.png" style="width:5.76042in;height:0.77292in" alt="7f558cb7-f1e9-417b-9892-3a2d62908b38" /><img src="media/image101.png" style="width:5.76181in;height:0.25417in" alt="3c74f306-675a-4cd1-bb6e-38525a76b6b0" /><img src="media/image102.png" style="width:5.75833in;height:0.27847in" alt="cd4df812-bc02-4ae4-a227-17ba9d664b1b" /><img src="media/image103.png" style="width:5.76042in;height:0.33958in" alt="0321198b-a4b1-45a8-9b7e-a9d53c6cd19f" /><img src="media/image104.png" style="width:5.76042in;height:0.29931in" alt="ad76aa09-f4e5-48ff-aa35-0af6e4c4dd8c" /><img src="media/image105.png" style="width:5.75903in;height:0.325in" alt="c010e646-d366-4a7f-a242-31df57bedfc3" /><img src="media/image106.png" style="width:5.76181in;height:0.29236in" alt="a14ce914-5381-408b-abf7-af2f21efaf4c" />

PASS

2.  Host服务器上电开机状态，DPU带外带外通过ipmi命令开、关、重启DPU。

<img src="media/image107.png" style="width:5.76458in;height:0.26875in" alt="8dbf20a6-9c18-41b1-98b6-e21592ca2bfe" /><img src="media/image108.png" style="width:5.76458in;height:0.60764in" alt="bd4cebe625f828f25b3b7690940517ef" /><img src="media/image109.png" style="width:5.76458in;height:0.32014in" alt="b7d0f3579313a1ab8422daa48743f23f" /><img src="media/image110.png" style="width:5.76458in;height:0.33611in" alt="d9407586221ec26af492b67ccda18063" /><img src="media/image111.png" style="width:5.75972in;height:0.35208in" alt="4d1ef28a-ee0d-4bef-a90c-4794661afff6" /><img src="media/image112.png" style="width:5.76458in;height:0.48264in" alt="c31d57ca-641c-430d-8a4a-50386fcab180" />

PASS

3.  登录Host服务器BMC web界面，查看DPU FRU信息。

<img src="media/image113.png" style="width:5.75972in;height:1.15208in" alt="7bfff1a1-282a-4ebd-9141-e86f0866bed8" />

PASS

4.  带外通过DPU BMC IP、Host BMC IP用ipmi命令查看DPU FRU信息。

<img src="media/image114.png" style="width:5.76042in;height:2.05347in" alt="32a23587-8d08-4dba-ac88-3984e5694607" />

PASS

5.  登录Host服务器BMC web界面，信息-系统信息-设备清单，查看DPU设备状态。

<img src="media/image115.png" style="width:5.76597in;height:2.34097in" alt="4d4ecbfe-3e0c-464b-a690-f833b1ec3a49" />

PASS

6.  登录Host服务器BMC web界面，信息-系统信息-网卡，查看DPU设备状态。

<img src="media/image116.png" style="width:5.76181in;height:2.65139in" alt="76f1fea4-aa22-42ff-b808-5efc576529b2" />

PASS

7.  登录Host服务器BMC web界面，查看DPU传感器信息。

<img src="media/image117.png" style="width:5.76181in;height:0.68958in" alt="f862f115-6dfb-43e4-8857-5434a3cfefaa" />

PASS

8.  带外通过DPU BMC IP用ipmi命令读取DPU传感器信息。

<img src="media/image118.png" style="width:5.76042in;height:0.14514in" alt="90cab39b-d226-4a01-aed9-f417d256f7be" /><img src="media/image119.png" style="width:5.75417in;height:0.19792in" alt="f0d0a5f5-ef22-4517-8f87-9590079cc2c8" />

PASS

9.  带外通过Host BMC IP用ipmi命令读取DPU传感器信息。

<img src="media/image120.png" style="width:5.76667in;height:0.25556in" alt="607b53ce-0e77-4099-93c5-aa78e66599d4" /><img src="media/image121.png" style="width:5.75417in;height:0.79167in" alt="9d1f1513-6564-4a7a-88fb-fc591248c0c3" />

PASS

10. 登录Host服务器BMC web界面，设置风扇为手动控制，转速控制为低转速，DPU系统下对芯片CPU加压，使用率100%，查看BMC告警日志。

<img src="media/image122.png" style="width:3.10694in;height:0.89097in" alt="593f49d8-d425-42a3-bccf-875693500a94" />

然后利用stress-ng --cpu \$(nproc) --cpu-load 100 --timeout 120s加压<img src="media/image123.png" style="width:5.76181in;height:0.58472in" alt="5163f81f-6ebd-4c9e-b757-e0b8bbdad0cb" /><img src="media/image124.png" style="width:5.76181in;height:0.96875in" alt="c542ca1f-06db-4fc7-b77d-3cd5567869cf" />

PASS

11\. 登录DPU BMC web界面，打开KVM，重启DPU系统，查看整个启动过程，进入DPU BIOS界面，查看显示状态，进入DPU系统，查看显示状态，进行输入操作。

<img src="media/image125.png" style="width:2.70764in;height:2.12431in" alt="75cd1db3c6716bdcc15787afa2242cff" /><img src="media/image126.png" style="width:2.88194in;height:2.20139in" alt="ee4c67bf7cda46b776ccd392144025bb" /><img src="media/image127.png" style="width:2.64653in;height:2.07569in" alt="7b01acc44188f68bc3ccabaac374958e" /><img src="media/image128.png" style="width:2.80139in;height:1.91806in" alt="b12fd33f-b7b3-43db-a600-bb1c251f0e70" /><img src="media/image129.png" style="width:2.58958in;height:2.03125in" alt="0350c85bc4e5f344962895b31c0897b4" />PASS

12.登录DPU BMC web界面，查看SCP、BMC、CPLD、IMU等版本信息，更新SCP、BMC、CPLD、IMU版本，再次登录DPU BMC web界面，查看SCP、BMC、CPLD、IMU等版本信息。

13.登录DPU BMC web界面，挂载虚拟镜像文件，打开KVM，安装DPU系统。

未测

14. ssh登录dpu bmc os，ssh root@192.168.1.200 ，并输入dpu os的密码

<img src="media/image130.png" style="width:3.11389in;height:1.87778in" alt="1d64da822404ca4a37a7a116f4e0d54a" />

27. DPU支持的PF数量

满规格63PF

<img src="media/image131.png" style="width:2.77639in;height:1.97292in" alt="d95c1fcb-09f8-4856-80f3-bb97570cc909" /><img src="media/image132.png" style="width:2.85764in;height:1.97708in" alt="a14e7f7d-c354-4142-9af0-2f42cf1cb553" /><img src="media/image133.png" style="width:2.81319in;height:2.06597in" alt="1a1613d933523b2e108ac27a3e08a2ec" /><img src="media/image134.png" style="width:2.83472in;height:2.09514in" alt="83b1a4762f978949f155178e97a976c1" />**系统主机侧有63个eth设备**

<img src="media/image135.png" style="width:2.58264in;height:2.55347in" alt="4e9b6350cf9bd5799faf97548045043f" /><img src="media/image136.png" style="width:2.96736in;height:2.54583in" alt="48069b2b0ab8b9749a00f208be390f3c" />

PASS

28. 网络性能

需要对跑、等待另一机台

29. 存储性能

<img src="media/image137.png" style="width:2.88542in;height:1.52708in" alt="5403f616-8403-48fa-bcd8-e2543e70f3bd" /><img src="media/image138.png" style="width:2.84583in;height:1.49861in" alt="72e08071-82a5-4b8c-ae43-baecfa9b1018" /><img src="media/image139.png" style="width:2.81667in;height:1.55903in" alt="3fb596b4-7c77-402f-8ea7-87eb446c1641" /><img src="media/image140.png" style="width:2.89306in;height:1.56875in" alt="471f3694-ca5a-4cb5-88a6-9658b06cb6fb" /><img src="media/image141.png" style="width:2.75347in;height:1.51806in" alt="5dfa1d2b-3ed3-4223-8a8e-b641132b0ac7" /><img src="media/image142.png" style="width:4.13958in;height:0.56389in" alt="6fd30989-fc50-438e-b72c-f2ff56182f04" /><img src="media/image143.png" style="width:2.67778in;height:1.58056in" alt="9ff106dc-d026-4bf5-b97d-2acfb7757e48" /><img src="media/image144.png" style="width:4.19792in;height:0.47917in" alt="c2bf8138-60ce-4289-bb8d-852de20729e5" /><img src="media/image145.png" style="width:4.08264in;height:1.56875in" alt="b4f07b45-e9d2-4d1f-9bef-b6248ea2ca99" /><img src="media/image146.png" style="width:2.79931in;height:1.43472in" alt="cb4fff8a-6c3d-4040-9d5c-ad8557f7bcf7" /><img src="media/image147.png" style="width:2.88194in;height:1.41667in" alt="19de227b-b815-4c61-8a4b-e00acd3edff6" />

PASS

30. DPU CPU稳定性测试

![](media/image148.emf)PASS

31. DPU内存稳定性测试

![](media/image149.emf)![](media/image150.emf)PASS

32. DPU管理网口Bond1稳定性测试

33. DPU数据网口Bond4稳定性测试

34. DPU系统稳定性测试

Bond1启动会直接拉低Bond4的速率、无法正常测试Fail

35. HOST服务器 reboot/

第一次测试![](media/image151.emf)第二次测试![](media/image152.emf)

36. HOST服务器DC Cycle

<img src="media/image153.jpeg" style="width:5.76806in;height:4.51795in" alt="C:\Users\王文超\Documents\xwechat_files\wxid_87vwarpdr3u022_8b53\temp\RWTemp\2026-01\eb8695daa0286ccb8e6b8dd1f9783706\ac069a0cf41f712e78a4803eb368910e.jpg" />DPU端memory压力进程被killed、Fail

37. HOST服务器AC Cycle

38. DPU reboot

39. DPU reset Cycle

40. DPU DC Cycle

41. X

42. x

43、云盘启动

<img src="media/image154.png" style="width:2.84375in;height:1.9125in" alt="cdddaaf1-77cc-4b0f-9afe-80863de7fa5e" /><img src="media/image155.png" style="width:2.71597in;height:1.10764in" alt="09658add-d4e4-439a-a0cc-4720716bd3b9" />

<img src="media/image156.png" style="width:2.60208in;height:2.10556in" alt="baef8113-255b-46f3-8016-56c8f7eaf424" /><img src="media/image157.png" style="width:3.10278in;height:2.08611in" alt="9e91365d842fa65cdf95ec79966a92c8" />

<img src="media/image158.png" style="width:4.02431in;height:2.825in" alt="b30d25902a2aa1298dd46dd8c32cacc4" />

点进去后一直重启无法进入Kylin系统

44. 网络虚拟化

<img src="media/image159.png" style="width:4.08542in;height:2.63611in" alt="1a0888e89e5fae6dd701eb1aba72eed2" /><img src="media/image160.png" style="width:4.15278in;height:2.66875in" alt="d94053fd-6869-4a12-9a94-b30163934097" /><img src="media/image161.png" style="width:3.94722in;height:3.11597in" alt="944e1d79-cfb8-40af-ab26-15bdd540f136" /><img src="media/image162.png" style="width:3.94097in;height:1.50694in" alt="90a1db54-04ad-429f-af72-752045d502d0" />

热重启后

<img src="media/image163.png" style="width:3.90417in;height:1.42778in" alt="7541c1d3-1bcd-4a9c-929e-8f5666fbdc0a" />

<img src="media/image164.png" style="width:3.86597in;height:1.54444in" alt="d6f135e3-7361-4ef3-9590-0381da17cba3" />

<img src="media/image165.png" style="width:3.87222in;height:0.30833in" alt="07ca55e9-fe42-44b9-b6aa-dbae84dadcb1" />

<img src="media/image166.png" style="width:3.87639in;height:0.44375in" alt="8af4e5da-2a69-4b58-b7b8-5b047d49be4b" />

<img src="media/image167.png" style="width:4.27083in;height:1.99248in" alt="C:\Users\王文超\Documents\xwechat_files\wxid_87vwarpdr3u022_8b53\temp\RWTemp\2026-01\aad1fdbce62691a0475ae591c945a414.png" />PASS

45. 存储虚拟化

<img src="media/image159.png" style="width:3.04514in;height:1.75625in" alt="1a0888e89e5fae6dd701eb1aba72eed2" /><img src="media/image160.png" style="width:3.56042in;height:2.28819in" alt="d94053fd-6869-4a12-9a94-b30163934097" /><img src="media/image161.png" style="width:3.72569in;height:2.94097in" alt="944e1d79-cfb8-40af-ab26-15bdd540f136" /><img src="media/image168.png" style="width:3.72153in;height:2.23542in" alt="35f7298a-30e5-4cf6-b0bd-f4da30759370" /><img src="media/image169.png" style="width:3.84375in;height:3.09722in" alt="cde8e0a3-3d9a-4378-81f1-6a338f6096be" /><img src="media/image170.png" style="width:4.25069in;height:3.78194in" alt="02de3adb-0237-4e2f-b7cf-c59db8d26160" /><img src="media/image171.png" style="width:3.58889in;height:3.21111in" alt="16e350a3-e845-41bb-9115-eb8c01884802" /><img src="media/image172.png" style="width:3.66389in;height:3.12986in" alt="2c7571f3-fca5-4813-b4c6-35af49ff32b3" /><img src="media/image173.png" style="width:3.69028in;height:3.03264in" alt="1e65f11c-276f-426f-909a-78bd29e059c8" /><img src="media/image174.png" style="width:3.67778in;height:2.99375in" alt="e541d1f2-9af6-401a-925d-a52efc2ab7c2" /><img src="media/image175.png" style="width:3.75903in;height:3.08958in" alt="18a3da48-c968-42ec-b55e-fcf5dd44dc26" /><img src="media/image176.png" style="width:3.75069in;height:2.94653in" alt="59bf0e86-831f-436a-99a2-2ecfd00f189b" /><img src="media/image177.png" style="width:3.43056in;height:2.71875in" alt="1f0fa9c4-ab0a-4f67-8d76-ec1ae20e4407" /><img src="media/image162.png" style="width:3.49375in;height:1.33611in" alt="90a1db54-04ad-429f-af72-752045d502d0" /><img src="media/image178.png" style="width:3.45694in;height:1.68681in" alt="4806d64a-6649-48c0-8033-7cc0dfe72e8d" /><img src="media/image179.png" style="width:5.625in;height:0.6875in" alt="a0a5efbbdd35b86c34be23d339a7a72e" /><img src="media/image180.png" style="width:3.87986in;height:2.56181in" alt="e486324f-d421-46c8-a519-3a9f0565306b" /><img src="media/image181.png" style="width:3.85208in;height:2.54375in" alt="c8ec311c-2e66-494b-899d-1a6bb68463ae" />

PASS

46. 虚拟化设备热插拔

**网络热插拔：**

<img src="media/image182.png" style="width:5.76597in;height:0.54028in" alt="5a4e77a6-d65a-4f00-b847-409cfc3c7ddb" />

<img src="media/image183.png" style="width:4.15278in;height:1.34583in" alt="5106bc6ec51df1d13c947137737942df" />

<img src="media/image184.png" style="width:4.13889in;height:1.04722in" alt="c47344c74253292252ba2a3dd8cc70a0" /><img src="media/image185.png" style="width:4.12569in;height:2.29028in" alt="b75c29887da4bce61a77495b143aa0c7" />

存储热插拔

<img src="media/image186.png" style="width:4.32014in;height:2.10764in" alt="884077025520f5d94adc3bf34ce0b056" /><img src="media/image187.png" style="width:4.34792in;height:1.06458in" alt="3a54f1357a22b1260a2b62bfb9598f7a" /><img src="media/image188.png" style="width:4.26597in;height:3.35903in" alt="43c2f526a673458f934a49712d7bf48e" />

47. DPU支持的VF数量

**SRIOV VF配置**

<img src="media/image189.png" style="width:5.50139in;height:0.35347in" alt="b001f6107198bc3666ed4a6b0bed70b3" /><img src="media/image190.png" style="width:4.61042in;height:2.57083in" alt="0ac96ac4-d044-451a-aad6-378d08c69ac8" />

<img src="media/image191.png" style="width:4.50694in;height:3.37778in" alt="f844d67c3a7aacadce5f12ff6b833231" />

DPU侧配置：/usr/share/jmnd/config/config.json

<img src="media/image192.png" style="width:4.55417in;height:2.46667in" alt="5465c8e8-5122-48f9-a3c6-ea07733391ae" />

<img src="media/image193.png" style="width:4.52986in;height:0.92917in" alt="736b8c9c-9984-40d3-b443-e6307601fdea" /><img src="media/image194.png" style="width:4.55833in;height:2.78681in" alt="f28ddd8f6f24de320ac84f8436125022" /><img src="media/image195.png" style="width:4.575in;height:1.90833in" alt="6e76b90e-e2f3-4de1-93ab-fc238d12938c" /><img src="media/image196.jpeg" style="width:4.59722in;height:2.58611in" alt="2d949d732411fa926e3314f1d3db3696" />

重新拉起<img src="media/image197.png" style="width:5.7625in;height:0.74444in" alt="0655e7335c8765b0efd611ea63d787fa" /><img src="media/image198.png" style="width:4.19444in;height:2.17431in" alt="919997f6a1a6405a056eee0e45c3e3e9" /><img src="media/image199.png" style="width:4.25278in;height:1.275in" alt="ceaa672111a227770ae5c31562d94466" /><img src="media/image200.png" style="width:4.29792in;height:1.36111in" alt="815edddb38d0bf92ae41f549b67afb46" /><img src="media/image201.png" style="width:4.36597in;height:1.89236in" alt="a4a7aac5-40a1-4d0f-a663-69e562fc70f2" /><img src="media/image202.png" style="width:4.31875in;height:1.40208in" alt="675b3938-7ce7-4aca-bff2-b6583bb4617e" />

依旧是掉了一个

VF依旧不可以生成

FAILE
