<span class="mark">5、当使用标卡时，使用串口连接器连接到标卡串口和电脑的USB接口</span>

6、通过XShell或其他串口软件连接到串口端口

7、重启服务器，通过XShell控制台，查看HuaWei MR/iMR卡初始化过程，预期结果A

8、在串口中输入123m，预期结果B

<img src="media/image1.jpeg" style="width:5.44514in;height:9.67986in" alt="bb95baab67ce87085b4f7f2870ee5b5c" />

\[root@bogon ~\]# lspci \| grep -i raid 18:00.0 RAID bus controller: Huawei Technologies Co., Ltd. Huawei Server SP686C RAID Controller Card (rev 21) \[root@bogon ~\]#

<span class="mark">SP686标卡没有实体串口、无法进行本项测试</span>

预期结果A：能够监控到HuaWei MR/iMR卡串口输出

预期结果B：输入123m后出现串口控制台提示符MegaMon0\>，并可以输入命令；切入MegaMon0，输入dmdiag pl dbg命令，该条命令大概要执行10min，然后RAID卡挂死，BMC有相关RAID卡failure的告警
