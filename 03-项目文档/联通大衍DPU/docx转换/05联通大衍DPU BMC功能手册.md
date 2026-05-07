## 1 DPU散热策略

> <img src="media/image1.png" style="width:4.46952in;height:3.07072in" />

## 2 BMC web展示

> <img src="media/image2.png" style="width:5.76806in;height:2.79861in" />
>
> 绿色代表当前电源状态。
>
> 注意：因为大衍DPU不具备业务自启动能力，所以执行下电和复位操作时，需要先将服务器OS下电。

1.  网络适配器显示

> 大衍DPU不支持MCTP协议，端口属性没有数据。
>
> <img src="media/image3.png" style="width:5.76806in;height:2.73403in" />

## 3 Fru信息展示

> <img src="media/image4.png" style="width:5.76806in;height:2.17083in" />
>
> <img src="media/image5.png" style="width:5.10353in;height:2.94755in" />

## 4 Version展示

> <img src="media/image6.png" style="width:5.76806in;height:3.99792in" />
>
> 已知问题：MCU版本获取不到，需要与DPU厂家联调。

## 5 门限传感器

> <img src="media/image7.png" style="width:5.76806in;height:1.5375in" />

## 6 IPMI命令

1）IPMI 命令控制DPU系统的开关机（该命令需要服务器OS处于下电状态）：

ipmitool raw 0x3c 0xf7 0x01：开机

ipmitool raw 0x3c 0xf7 0x02：关机

ipmitool raw 0x3c 0xf7 0x03：重启

2）IPMI 命令获取DPU系统的开关机状态：

查询命令：ipmitool raw 0x3c 0xf6 0x00

返回值是 00 表示处于关机状态， 返回值 01表示处于开机状态。

3）Host BMC SOL切换到DPU

- 使用ssh登录到DPU的bmc，使用命令把串口切换到ncsi。

> \#串口切换到ncsi：i2cset -f -y 4 0x74 0xbe 0x2f
>
> \#查看当前串口：i2cget -f -y 4 0x74 0xbe

<img src="media/image8.png" style="width:4.54756in;height:0.81331in" />

- 打开串口重定向：ipmitool sol activate

<img src="media/image9.png" style="width:4.85688in;height:1.13966in" />

- 串口方向切换到DPU OS：

> Ipmitool raw 0x30 0x91 0xdb 0x07 0x00 0x17 0x02 0x0c

<img src="media/image10.png" style="width:5.7671in;height:0.96998in" />

- 串口方向切换到Host OS：

> Ipmitool raw 0x30 0x91 0xdb 0x07 0x00 0x17 0x02 0x00

<img src="media/image10.png" style="width:5.77168in;height:0.97075in" />

## 7 Redfish接口

1)  获取网卡资源信息Redfish接口：

获取网卡资源列表URL：<https://device_ip/redfish/v1/Chassis/chassis_id/NetworkAdapters>

device_ip 为 BMC IP 地址，chassis_id 为机箱资源 ID

获取具体网卡信息URL：<https://device_ip/redfish/v1/Chassis/chassis_id/NetworkAdapters/networkadapters_id>

device_ip 为 BMC IP 地址，chassis_id 为机箱资源 ID， networkadapters_id 网卡 ID

2)  VNC服务开关Redfish路径：

URL：<https://device_ip/redfish/v1/Managers/1/NetworkProtocol>

device_ip 为BMC IP 地址，同时指定request body，格式为：

{

    "Oem": {

        "Huawei": {

            "VNC": {

                "ProtocolEnabled": false

            }

        }

    }

}

3)  服务器启动项设置Redfish路径：

URL：<https://device_ip/redfish/v1/Systems/1>

device_ip 为BMC IP 地址，同时指定request body，格式为：

{

    "Boot": {

        "BootSourceOverrideTarget": XXX,

        "BootSoureOverrideEnabled": XXX

    }

}

4.  DPU卡资源信息Redfish路径：

<https://device_ip/redfish/v1/Chassis/chassis_id/NetworkAdapters/networkadapters_id>

device_ip 为 BMC IP 地址，chassis_id 为机箱资源 ID， networkadapters_id 网卡 ID

5.  DPU卡端口信息Redfish路径：

<https://device_ip/redfish/v1/Chassis/chassis_id/NetworkAdapters/networkadapters_id>/NetworkPorts/port_id

device_ip 为 BMC IP 地址，chassis_id 为机箱资源 ID， networkadapters_id 网卡 ID，port_id为 网卡端口ID
