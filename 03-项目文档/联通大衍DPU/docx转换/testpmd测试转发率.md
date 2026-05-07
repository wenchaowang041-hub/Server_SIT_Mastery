测试转发率：

收发两端都执行如下命令：

systemctl restart vdev

systemctl restart vhost

systemctl restart ovsdb

systemctl restart ovs

dpdk-devbind.py -b vfio-pci 0000:01:01.2

systemctl stop vdev

systemctl stop vhost

systemctl stop ovsdb

systemctl stop ovs

发端发包命令：

testpmd -l 2-11 -- --txd=1024 --rxd=1024 --rxq=8 --txq=8 --total-num-mbufs=1000000 --burst=64 --nb-cores=8 --auto-start --forward-mode=flowgen --txpkts=1518 --stats-period 1

收端收包命令：

testpmd -l 2-11 -- --txd=1024 --rxd=1024 --rxq=8 --txq=8 --total-num-mbufs=1000000 --burst=64 --nb-cores=8 --auto-start --forward-mode=rxonly --stats-period 1<img src="media/image1.jpeg" style="width:5.55556in;height:3.78472in" alt="21886d24b70617396c9e5c88a7419b6e" />
