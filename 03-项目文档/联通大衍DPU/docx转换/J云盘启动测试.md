**云盘镜像准备：**

1、上传云盘系统到host os下

<img src="media/image1.png" style="width:5.76806in;height:1.53819in" />

2、cd进入到对应目录里执行：cat Kylin-Server-V10-SP3-2303-ARM64-YunBao-25.11.28.qcow2_0\* \> Kylin-Server-V10-SP3-2303-ARM64-YunBao-25.11.28.qcow2

<img src="media/image2.png" style="width:5.76806in;height:0.19097in" />

3、计算qcow2镜像的md5值是：6091ed239e97bd9acb12d0b7be137125

命令为： md5sum Kylin-Server-V10-SP3-2303-ARM64-YunBao-25.11.28.qcow2

<img src="media/image3.png" style="width:5.76806in;height:0.26111in" />

4、将生成的qcow2文件转换成raw格式(需要安装qemu-img工具)： qemu-img convert -O raw Kylin-Server-V10-SP3-2303-ARM64-YunBao-25.11.28.qcow2 Kylin-Server-V10-SP3-2303-ARM64-YunBao-25.11.28.raw

<img src="media/image4.png" style="width:5.76806in;height:0.25903in" />

5、使用生成的raw格式镜像作为云盘启动裸机

**云盘配置：**

1、将云盘镜像放到/data/host_disk_images目录

<img src="media/image5.png" style="width:5.76806in;height:1.98403in" />

**2、**在/usr/share/jmnd/example/scenario/路径下，创建云盘裸金属适配配置文件bm_test.json

<img src="media/image6.png" style="width:5.76806in;height:2.34028in" />

<img src="media/image7.png" style="width:5.29771in;height:6.90625in" />

<img src="media/image8.png" style="width:5.76806in;height:1.73889in" />

<img src="media/image9.png" style="width:5.76806in;height:2.77639in" />

<img src="media/image10.png" style="width:5.76806in;height:4.18889in" />

问题解决：

1.  先停掉bm_local

<img src="media/image11.png" style="width:5.76806in;height:4.19167in" />

<img src="media/image12.png" style="width:5.76806in;height:0.40069in" />

重新拉起卡侧云盘裸金属实例，依然报错

<img src="media/image13.png" style="width:5.76806in;height:1.49236in" />

<img src="media/image14.png" style="width:5.76806in;height:6.96667in" />

<img src="media/image15.png" style="width:4.0528in;height:1.05268in" />

**重新进行问题解决：**

1、重新修改bm_test.json

<img src="media/image16.png" style="width:5.76806in;height:6.09861in" />

重新拉起卡侧云盘裸金属实例

<img src="media/image17.png" style="width:5.76806in;height:2.06528in" />

<img src="media/image18.png" style="width:5.76806in;height:2.76875in" />

重启主机，进bios，可以看到多出了一个kylin系统启动项

<img src="media/image19.png" style="width:5.76806in;height:3.64306in" />

点进去后，可以到系统登录界面

<img src="media/image20.png" style="width:5.76806in;height:1.86528in" />

**当前云盘用户名密码不详**

**满规格63PF配置**

**先停掉前边的bm.json**

<img src="media/image21.png" style="width:5.76806in;height:3.63611in" />

<img src="media/image22.png" style="width:3.68437in;height:1.09478in" />

**注意厂家提供的config.json文件括号确实，会导致服务起不来，自行修改后服务可起来**

**文件内容如下：**

<img src="media/image23.png" style="width:3.10539in;height:8.0635in" />

<img src="media/image24.png" style="width:5.76806in;height:1.21806in" />

<img src="media/image25.png" style="width:5.76806in;height:1.39167in" />

**…**

<img src="media/image26.png" style="width:5.76806in;height:1.87569in" />

**热重启服务器reboot**

**进到系统后会发现主机侧有63个eth设备**

<img src="media/image27.png" style="width:5.04167in;height:8.37778in" />

**SRIOV VF配置**

1、先关闭前边的bm_local.json服务

<img src="media/image28.png" style="width:4.6983in;height:3.6558in" />

**…**

<img src="media/image29.png" style="width:4.71547in;height:4.54856in" />

2.  **配置/usr/share/jmnd/config/config.json文件**

<img src="media/image30.png" style="width:5.76806in;height:1.20486in" />

<img src="media/image31.png" style="width:5.76806in;height:3.42361in" />

<img src="media/image32.png" style="width:5.76806in;height:1.07569in" />

**热重启服务器**

**进到主机系统下，查看SRIOV设备**

<img src="media/image33.png" style="width:5.76806in;height:1.28819in" />

<img src="media/image34.png" style="width:4.47387in;height:1.15794in" />

**编译加载驱动jmnd_sriov.ko**

<img src="media/image35.png" style="width:5.76806in;height:2.91458in" />

**无法生成VF**

<img src="media/image36.png" style="width:5.76806in;height:1.14514in" />

**查询网络设备，发现没有网络端口**

<img src="media/image37.png" style="width:5.76806in;height:2.27361in" />
