26. DPU BMC

<!-- -->

1.  Host服务器上电未开机状态，DPU带外通过ipmi命令开、关、重启DPU。

    <img src="media/image1.png" style="width:5.76042in;height:0.77292in" alt="7f558cb7-f1e9-417b-9892-3a2d62908b38" /><img src="media/image2.png" style="width:5.76181in;height:0.25417in" alt="3c74f306-675a-4cd1-bb6e-38525a76b6b0" /><img src="media/image3.png" style="width:5.75833in;height:0.27847in" alt="cd4df812-bc02-4ae4-a227-17ba9d664b1b" /><img src="media/image4.png" style="width:5.76042in;height:0.33958in" alt="0321198b-a4b1-45a8-9b7e-a9d53c6cd19f" /><img src="media/image5.png" style="width:5.76042in;height:0.29931in" alt="ad76aa09-f4e5-48ff-aa35-0af6e4c4dd8c" /><img src="media/image6.png" style="width:5.75903in;height:0.325in" alt="c010e646-d366-4a7f-a242-31df57bedfc3" /><img src="media/image7.png" style="width:5.76181in;height:0.29236in" alt="a14ce914-5381-408b-abf7-af2f21efaf4c" />

    PASS

2.  Host服务器上电开机状态，DPU带外带外通过ipmi命令开、关、重启DPU。

    <img src="media/image8.png" style="width:5.76458in;height:0.26875in" alt="8dbf20a6-9c18-41b1-98b6-e21592ca2bfe" /><img src="media/image9.png" style="width:5.76458in;height:0.60764in" alt="bd4cebe625f828f25b3b7690940517ef" /><img src="media/image10.png" style="width:5.76458in;height:0.32014in" alt="b7d0f3579313a1ab8422daa48743f23f" /><img src="media/image11.png" style="width:5.76458in;height:0.33611in" alt="d9407586221ec26af492b67ccda18063" /><img src="media/image12.png" style="width:5.75972in;height:0.35208in" alt="4d1ef28a-ee0d-4bef-a90c-4794661afff6" /><img src="media/image13.png" style="width:5.76458in;height:0.48264in" alt="c31d57ca-641c-430d-8a4a-50386fcab180" />

    PASS

3.  登录Host服务器BMC web界面，查看DPU FRU信息。

    <img src="media/image14.png" style="width:5.75972in;height:1.15208in" alt="7bfff1a1-282a-4ebd-9141-e86f0866bed8" />

    PASS

4.  带外通过DPU BMC IP、Host BMC IP用ipmi命令查看DPU FRU信息。

    <img src="media/image15.png" style="width:5.76042in;height:2.05347in" alt="32a23587-8d08-4dba-ac88-3984e5694607" />

    PASS

5.  登录Host服务器BMC web界面，信息-系统信息-设备清单，查看DPU设备状态。

    <img src="media/image16.png" style="width:5.76597in;height:2.34097in" alt="4d4ecbfe-3e0c-464b-a690-f833b1ec3a49" />

    PASS

6.  登录Host服务器BMC web界面，信息-系统信息-网卡，查看DPU设备状态。

    <img src="media/image17.png" style="width:5.76181in;height:2.65139in" alt="76f1fea4-aa22-42ff-b808-5efc576529b2" />

    PASS

7.  登录Host服务器BMC web界面，查看DPU传感器信息。

    <img src="media/image18.png" style="width:5.76181in;height:0.68958in" alt="f862f115-6dfb-43e4-8857-5434a3cfefaa" />

    PASS

8.  带外通过DPU BMC IP用ipmi命令读取DPU传感器信息。

    <img src="media/image19.png" style="width:5.76042in;height:0.14514in" alt="90cab39b-d226-4a01-aed9-f417d256f7be" /><img src="media/image20.png" style="width:5.75417in;height:0.19792in" alt="f0d0a5f5-ef22-4517-8f87-9590079cc2c8" />

    PASS

9.  带外通过Host BMC IP用ipmi命令读取DPU传感器信息。

    <img src="media/image21.png" style="width:5.76667in;height:0.25556in" alt="607b53ce-0e77-4099-93c5-aa78e66599d4" /><img src="media/image22.png" style="width:5.75417in;height:0.79167in" alt="9d1f1513-6564-4a7a-88fb-fc591248c0c3" />

    PASS

10. 登录Host服务器BMC web界面，设置风扇为手动控制，转速控制为低转速，DPU系统下对芯片CPU加压，使用率100%，查看BMC告警日志。

    <img src="media/image23.png" style="width:3.10694in;height:0.89097in" alt="593f49d8-d425-42a3-bccf-875693500a94" />

    然后利用stress-ng --cpu \$(nproc) --cpu-load 100 --timeout 120s加压<img src="media/image24.png" style="width:5.76181in;height:0.58472in" alt="5163f81f-6ebd-4c9e-b757-e0b8bbdad0cb" /><img src="media/image25.png" style="width:5.76181in;height:0.96875in" alt="c542ca1f-06db-4fc7-b77d-3cd5567869cf" />

    PASS

    11\. 登录DPU BMC web界面，打开KVM，重启DPU系统，查看整个启动过程，进入DPU BIOS界面，查看显示状态，进入DPU系统，查看显示状态，进行输入操作。

    <img src="media/image26.png" style="width:2.70764in;height:2.12431in" alt="75cd1db3c6716bdcc15787afa2242cff" /><img src="media/image27.png" style="width:2.88194in;height:2.20139in" alt="ee4c67bf7cda46b776ccd392144025bb" /><img src="media/image28.png" style="width:2.64653in;height:2.07569in" alt="7b01acc44188f68bc3ccabaac374958e" /><img src="media/image29.png" style="width:2.80139in;height:1.91806in" alt="b12fd33f-b7b3-43db-a600-bb1c251f0e70" /><img src="media/image30.png" style="width:2.58958in;height:2.03125in" alt="0350c85bc4e5f344962895b31c0897b4" />PASS

    12.登录DPU BMC web界面，查看SCP、BMC、CPLD、IMU等版本信息，更新SCP、BMC、CPLD、IMU版本，再次登录DPU BMC web界面，查看SCP、BMC、CPLD、IMU等版本信息。

    <img src="media/image31.png" style="width:1.44792in;height:1.05903in" alt="b9a44a5d-434e-4788-90db-9942cd41003a" /><img src="media/image32.png" style="width:1.38542in;height:1.10347in" alt="1e4addbe-ac75-402f-9737-80b3a84fc2af" /><img src="media/image33.png" style="width:1.30278in;height:1.09861in" alt="3ce24b92-e250-4237-8931-c85b138afd25" /><img src="media/image34.png" style="width:1.33056in;height:1.06042in" alt="8342f73d-0386-484b-92db-2c623a7d4655" /><img src="media/image35.png" style="width:1.45208in;height:1.28333in" alt="2926ff53ac59b92083a632957a2650ff" /><img src="media/image36.png" style="width:3.73125in;height:1.71875in" alt="060df851285044ee68934be67d38f95d" />

    由于SCP、BMC、CPLD、IMU更新前后为同一版本号、更新功能正常

    PASS

    13.登录DPU BMC web界面，挂载虚拟镜像文件，打开KVM，安装DPU系统。<img src="media/image37.png" style="width:2.87222in;height:1.66806in" alt="ce4abea40ebf10e1e4f477c1308532d4" /><img src="media/image38.png" style="width:5.76458in;height:6.27639in" alt="78a17ef7672dea8fd1292894b6971dea" /><img src="media/image39.png" style="width:5.76389in;height:4.51458in" alt="1afee58c89e18a5d6090a5a70d326132" /><img src="media/image40.png" style="width:5.76389in;height:4.51458in" alt="5be41068098737847693de428946ce43" /><img src="media/image41.png" style="width:5.76389in;height:4.51458in" alt="91519d15f8df10e87a1830afaf93fc02" /><img src="media/image42.png" style="width:5.76181in;height:4.93542in" alt="4b151e8a311b9e183fb6c627c063a512" />

    PASS

<!-- -->

14. ssh登录dpu bmc os，ssh root@192.168.1.200 ，并输入dpu os的密码

    <img src="media/image43.png" style="width:2.83889in;height:1.80069in" alt="1d64da822404ca4a37a7a116f4e0d54a" /><img src="media/image44.png" style="width:2.71042in;height:1.71528in" alt="4eca084f-ef53-4b28-840b-50646e5be5b1" />

    PASS
