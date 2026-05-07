44. DPU支持的VF数量

**SRIOV VF配置**

<img src="media/image1.png" style="width:5.50139in;height:0.35347in" alt="b001f6107198bc3666ed4a6b0bed70b3" /><img src="media/image2.png" style="width:4.61042in;height:2.57083in" alt="0ac96ac4-d044-451a-aad6-378d08c69ac8" />

<img src="media/image3.png" style="width:4.50694in;height:3.37778in" alt="f844d67c3a7aacadce5f12ff6b833231" />

DPU侧配置：/usr/share/jmnd/config/config.json

<img src="media/image4.png" style="width:4.55417in;height:2.46667in" alt="5465c8e8-5122-48f9-a3c6-ea07733391ae" />

<img src="media/image5.png" style="width:4.52986in;height:0.92917in" alt="736b8c9c-9984-40d3-b443-e6307601fdea" /><img src="media/image6.png" style="width:4.55833in;height:2.78681in" alt="f28ddd8f6f24de320ac84f8436125022" /><img src="media/image7.png" style="width:4.575in;height:1.90833in" alt="6e76b90e-e2f3-4de1-93ab-fc238d12938c" /><img src="media/image8.jpeg" style="width:4.59722in;height:2.58611in" alt="2d949d732411fa926e3314f1d3db3696" />

重新拉起<img src="media/image9.png" style="width:5.7625in;height:0.74444in" alt="0655e7335c8765b0efd611ea63d787fa" /><img src="media/image10.png" style="width:4.19444in;height:2.17431in" alt="919997f6a1a6405a056eee0e45c3e3e9" /><img src="media/image11.png" style="width:4.25278in;height:1.275in" alt="ceaa672111a227770ae5c31562d94466" /><img src="media/image12.png" style="width:4.29792in;height:1.36111in" alt="815edddb38d0bf92ae41f549b67afb46" />

\# lspci \|grep 1f53:1000 此时生成4个网络设备

但是执行echo 255 \> /sys/bus/pci/devices/0000\\1b\\00.0/sriov_numvfs

不会生成vf

\[root@localhost sriov-v1.0\]# echo 255 \> /sys/bus/pci/devices/0000\\1b\\00.0/sriov_numvfs

\[root@localhost sriov-v1.0\]# echo 255 \> /sys/bus/pci/devices/0000\\1c\\00.0/sriov_numvfs

\[root@localhost sriov-v1.0\]# echo 255 \> /sys/bus/pci/devices/0000\\1d\\00.0/sriov_numvfs

\[root@localhost sriov-v1.0\]# echo 255 \> /sys/bus/pci/devices/0000\\1e\\00.0/sriov_numvfs

上传以下配置文件解决echo 255 \> /sys/bus/pci/devices/0000\\1b\\00.0/sriov_numvfs无法生成vf的问题![](media/image13.emf)

注：在dpu测执行以下操作

ll /usr/lib64/jmnd_vdev.so

413 rm /usr/lib64/jmnd_vdev.so

414 ls

415 mv jmnd_vdev.so.corsica.dev.0.0.13613 /usr/lib64/

416 ln -s /usr/lib64/jmnd_vdev.so jmnd_vdev.so.corsica.dev.0.0.13613

417 ll /usr/lib64/jmnd_vdev.so

418 ll

419 rm jmnd_vdev.so.corsica.dev.0.0.13613

420 ln -s /usr/lib64/jmnd_vdev.so.corsica.dev.0.0.13613 /usr/lib64/jmnd_vdev.so

421 ll /usr/lib64/jmnd_vdev.so

423 reboot

然后重新拉起业务

在服务器端放入sriov-v1.0解压make然后安装、<img src="media/image14.png" style="width:5.76597in;height:3.20625in" alt="a0d4d0fcdb5d0cbc85607358dc701589" />

PASS
