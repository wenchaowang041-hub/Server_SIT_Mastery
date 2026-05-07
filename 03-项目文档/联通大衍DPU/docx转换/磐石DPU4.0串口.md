# DPU的bmc中

使用ssh登录到DPU的bmc，使用命令把串口切换到ncsi

\#串口切换到ncsi：i2cset -f -y 4 0x74 0xbe 0x2f

\#查看当前串口：i2cget -f -y 4 0x74 0xbe

\#串口切换到bmc：i2cset -f -y 4 0x74 0xbe 0x3b

# 服务器的bmc中

使用ssh登录到服务器的bmc中，打开两个窗口，

第一个窗口：ipmcset -t sol -d activate -v 1 0

第二个窗口：ipmcset -d serialdir -v 4

返回到第一个窗口，可以通过串口访问DPU的OS。
