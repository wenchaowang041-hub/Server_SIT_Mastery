\[root@davinci-mini ~\]# lspci -v \| grep -i -A5 -B5 "usb.\*3\\xhci\\typec"

lspci: Unable to load libkmod resources: error -2

Capabilities: \[180\] Multicast

Capabilities: \[1c0\] Secondary PCI Express

Capabilities: \[200\] Vendor Specific Information: ID=001a Rev=0 Len=000 \<?\>

Kernel driver in use: pcieport

0000:04:00.0 USB controller: ASMedia Technology Inc. ASM2142 USB 3.1 Host Controller (prog-if 30 \[XHCI\])

Subsystem: ASMedia Technology Inc. ASM2142 USB 3.1 Host Controller

Flags: bus master, fast devsel, latency 0

Memory at e0200000 (64-bit, non-prefetchable) \[size=32K\]

Capabilities: \[50\] MSI: Enable- Count=1/8 Maskable- 64bit+

Capabilities: \[68\] MSI-X: Enable+ Count=8 Masked-

Capabilities: \[78\] Power Management version 3

Capabilities: \[80\] Express Legacy Endpoint, MSI 00

Capabilities: \[100\] Advanced Error Reporting

Capabilities: \[200\] Secondary PCI Express

Capabilities: \[300\] Latency Tolerance Reporting

Capabilities: \[400\] L1 PM Substates

Kernel driver in use: xhci_hcd

0000:07:00.0 USB controller: ASMedia Technology Inc. ASM2142 USB 3.1 Host Controller (prog-if 30 \[XHCI\])

Subsystem: ASMedia Technology Inc. ASM2142 USB 3.1 Host Controller

Flags: bus master, fast devsel, latency 0

Memory at e0300000 (64-bit, non-prefetchable) \[size=32K\]

Capabilities: \[50\] MSI: Enable- Count=1/8 Maskable- 64bit+

Capabilities: \[68\] MSI-X: Enable+ Count=8 Masked-

Capabilities: \[78\] Power Management version 3

Capabilities: \[80\] Express Legacy Endpoint, MSI 00

Capabilities: \[100\] Advanced Error Reporting

Capabilities: \[200\] Secondary PCI Express

Capabilities: \[300\] Latency Tolerance Reporting

Capabilities: \[400\] L1 PM Substates

Kernel driver in use: xhci_hcd

0000:09:00.0 Network controller: Realtek Semiconductor Co., Ltd. RTL8822CE 802.11ac PCIe Wireless Network Adapter

Subsystem: Realtek Semiconductor Co., Ltd. RTL8822CE 802.11ac PCIe Wireless Network Adapter

Flags: fast devsel, IRQ 255

I/O ports at 2000 \[disabled\] \[size=256\]
