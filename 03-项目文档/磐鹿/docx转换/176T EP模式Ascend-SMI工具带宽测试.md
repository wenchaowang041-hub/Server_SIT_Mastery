\[root@bogon ~\]# npu -smi

-bash: npu: 未找到命令

\[root@bogon ~\]# npu-smi info

grep: 警告：/ 前有多余的 \\

grep: 警告：/ 前有多余的 \\

+--------------------------------------------------------------------------------------- -----------------+

\| npu-smi 24.1.rc4.b999 Version: 24.1.rc4.b999 \|

+-------------------------------+-----------------+------------------------------------- -----------------+

\| NPU Name \| Health \| Power(W) Temp(C) Hugep ages-Usage(page) \|

\| Chip Device \| Bus-Id \| AICore(%) Memory-Usage(MB) \|

+===============================+=================+===================================== =================+

\| 0 310P1 \| OK \| NA 33 0 / 0 \|

\| 0 0 \| 0000:02:00.0 \| 0 1923 / 44215 \|

+===============================+=================+===================================== =================+

+-------------------------------+-----------------+------------------------------------- -----------------+

\| NPU Chip \| Process id \| Process name \| Process m emory(MB) \|

+===============================+=================+===================================== =================+

\| No running processes found in NPU 0 \|

+===============================+=================+===================================== =================+

\[root@bogon ~\]# source /usr/local/Ascend/cann/set_env.sh

-bash: /usr/local/Ascend/cann/set_env.sh: No such file or directory

\[root@bogon ~\]# source /usr/local/Ascend/cann/

-bash: /usr/local/Ascend/cann/: No such file or directory

\[root@bogon ~\]# source /usr/local/Ascend/

ascend-toolkit/ host_servers_remove.sh host_services_setup.sh version.info

develop/ host_servers_setup.sh host_sys_init.sh

driver/ host_services_exit.sh toolbox/

\[root@bogon ~\]# source /usr/local/Ascend/

ascend-toolkit/ host_servers_remove.sh host_services_setup.sh version.info

develop/ host_servers_setup.sh host_sys_init.sh

driver/ host_services_exit.sh toolbox/

\[root@bogon ~\]# source /usr/local/Ascend/ascend-toolkit/

8.1/ 8.1.RC1/ latest/ set_env.sh

\[root@bogon ~\]# source /usr/local/Ascend/ascend-toolkit/

8.1/ 8.1.RC1/ latest/ set_env.sh

\[root@bogon ~\]# source /usr/local/Ascend/ascend-toolkit/set_env.sh

\[root@bogon ~\]# ascend-dmi

-bash: ascend-dmi: 未找到命令

\[root@bogon ~\]# source /usr/local/Ascend/

ascend-toolkit/ host_servers_remove.sh host_services_setup.sh version.info

develop/ host_servers_setup.sh host_sys_init.sh

driver/ host_services_exit.sh toolbox/

\[root@bogon ~\]# source /usr/local/Ascend/

ascend-toolkit/ host_servers_remove.sh host_services_setup.sh version.info

develop/ host_servers_setup.sh host_sys_init.sh

driver/ host_services_exit.sh toolbox/

\[root@bogon ~\]# source /usr/local/Ascend/toolbox/

7.0.T10/ latest/ set_env.sh

\[root@bogon ~\]# source /usr/local/Ascend/toolbox/

7.0.T10/ latest/ set_env.sh

\[root@bogon ~\]# source /usr/local/Ascend/toolbox/

7.0.T10/ latest/ set_env.sh

\[root@bogon ~\]# source /usr/local/Ascend/toolbox/set_env.sh

\[root@bogon ~\]# npu-smi info \| grep -A5 "Device 0"

grep: 警告：/ 前有多余的 \\

grep: 警告：/ 前有多余的 \\

\[root@bogon ~\]# ascend-dmi --bw -t h2d -d 0 -s 8388608 --et 100

grep: 警告：/ 前有多余的 \\

grep: 警告：/ 前有多余的 \\

This test will affect the business on this server. To ensure the correctness and accuracy of the test, perform the operation separately.Do you want to continue?(Y/N)y

Host to Device Test

Device 0: Ascend 310P1.

-------------------------------------------------------------------

ID Size(Bytes) Execute Times Bandwidth(GB/s) Elapsed Time(us)

-------------------------------------------------------------------

0 8388608 100 6.106278 1373.77

-------------------------------------------------------------------

\[root@bogon ~\]# ascend-dmi --bw -t d2h -d 0 -s 8388608 --et 100

grep: 警告：/ 前有多余的 \\

grep: 警告：/ 前有多余的 \\

This test will affect the business on this server. To ensure the correctness and accuracy of the test, perform the operation separately.Do you want to continue?(Y/N)y

Device to Host Test

Device 0: Ascend 310P1.

-------------------------------------------------------------------

ID Size(Bytes) Execute Times Bandwidth(GB/s) Elapsed Time(us)

-------------------------------------------------------------------

0 8388608 100 6.672553 1257.18

-------------------------------------------------------------------

\[root@bogon ~\]# ascend-dmi --bw -t h2d -d 0 --et 100

grep: 警告：/ 前有多余的 \\

grep: 警告：/ 前有多余的 \\

This test will affect the business on this server. To ensure the correctness and accuracy of the test, perform the operation separately.Do you want to continue?(Y/N)y

Host to Device Test

Device 0: Ascend 310P1.

----------------------------------------------------------------

Size(Bytes) Execute Times Bandwidth(GB/s) Elapsed Time(us)

----------------------------------------------------------------

2 100 0.000178 11.21

4 100 0.000357 11.21

8 100 0.000714 11.21

16 100 0.001428 11.21

32 100 0.002856 11.21

64 100 0.005592 11.44

128 100 0.011423 11.21

256 100 0.022370 11.44

512 100 0.045691 11.21

1024 100 0.089478 11.44

2048 100 0.182765 11.21

4096 100 0.365529 11.21

8192 100 0.715828 11.44

16384 100 1.431656 11.44

32768 100 2.051328 15.97

65536 100 3.393554 19.31

131072 100 4.433515 29.56

262144 100 4.908534 53.41

524288 100 5.090332 103.00

1048576 100 5.653016 185.49

2097152 100 5.923295 354.05

4194304 100 6.030917 695.47

8388608 100 6.093587 1376.63

16777216 100 6.165126 2721.31

33554432 100 6.189528 5421.16

----------------------------------------------------------------

\[root@bogon ~\]# ascend-dmi --bw -t d2h -d 0 --et 100

grep: 警告：/ 前有多余的 \\

grep: 警告：/ 前有多余的 \\

This test will affect the business on this server. To ensure the correctness and accuracy of the test, perform the operation separately.Do you want to continue?(Y/N)y

Device to Host Test

Device 0: Ascend 310P1.

----------------------------------------------------------------

Size(Bytes) Execute Times Bandwidth(GB/s) Elapsed Time(us)

----------------------------------------------------------------

2 100 0.000171 11.68

4 100 0.000342 11.68

8 100 0.000685 11.68

16 100 0.001370 11.68

32 100 0.003050 10.49

64 100 0.005478 11.68

128 100 0.010737 11.92

256 100 0.022370 11.44

512 100 0.044739 11.44

1024 100 0.087652 11.68

2048 100 0.175305 11.68

4096 100 0.350610 11.68

8192 100 0.701219 11.68

16384 100 1.374390 11.92

32768 100 1.991869 16.45

65536 100 3.088516 21.22

131072 100 4.328786 30.28

262144 100 5.416313 48.40

524288 100 5.741575 91.31

1048576 100 6.168368 169.99

2097152 100 6.458218 324.73

4194304 100 6.603673 635.15

8388608 100 6.667495 1258.13

16777216 100 6.738365 2489.81

33554432 100 6.773390 4953.86

----------------------------------------------------------------

\[root@bogon ~\]#
