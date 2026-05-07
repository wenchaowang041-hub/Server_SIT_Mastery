# **DPU 稳定性测试方案**

## **文档概述**

本文档详细描述了在 Host 服务器上进行 DPU（Data Processing Unit）稳定性测试的完整方案。测试包括两个主要部分：

1.  

**DC Cycle 测试**：验证 DPU 在电源中断情况下的稳定性

2.  
3.  

**Warm Reboot 测试**：验证 Host 服务器反复重启过程中 DPU 的稳定性

4.  

## **一、测试环境信息**

### **1.1 设备信息**

| 设备类型        | IP 地址        | 用户名        | 密码       | 备注         |
|:----------------|:---------------|:--------------|:-----------|:-------------|
| Host 服务器 OS  | 10.121.177.131 | root          | @qwer1234! | 主测试机     |
| Host 服务器 BMC | 10.121.177.65  | Administrator | Admin@9000 | 带外管理     |
| DPU 卡 OS       | 10.121.176.107 | root          | qwe!@#123  | DPU 操作系统 |
| DPU 卡 BMC      | 10.121.177.209 | root          | 0penBmc    | DPU 带外管理 |

### **1.2 测试拓扑**

text

Host 服务器 (10.121.177.131)

├── BMC (10.121.177.65)

├── DPU OS (10.121.176.107)

└── DPU BMC (10.121.177.209)

## **二、DC Cycle 测试方案**

### **2.1 测试目标**

验证 DPU 在电源中断（拔电）后内存数据的持久性和恢复能力。

### **2.2 测试流程**

1.  

DPU 运行高负载内存压力测试

2.  
3.  

执行电源中断（DC Cycle）

4.  
5.  

上电后验证 DPU 状态

6.  
7.  

重复 300 次循环

8.  

### **2.3 准备工作**

#### **2.3.1 在 Host 上创建测试目录**

bash

mkdir -p ~/dpu_dc_cycle_test/{scripts,logs,results}cd ~/dpu_dc_cycle_test

#### **2.3.2 配置 SSH 免密登录**

bash

*\# 生成 SSH 密钥*

ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""

*\# 配置到 DPU*

ssh-copy-id root@10.121.176.107

*\# 测试连接*ssh root@10.121.176.107 "hostname"

#### **2.3.3 安装必要工具**

bash

*\# Host 服务器*

yum install -y ipmitool expect tmux*\# 或*apt install -y ipmitool expect tmux

### **2.4 DPU 压力测试部署**

#### **2.4.1 登录 DPU 并安装测试工具**

bash

ssh root@10.121.176.107

*\# 安装压力测试工具*if command -v apt &\>/dev/null; then

apt update && apt install -y stress-ngelif command -v yum &\>/dev/null; then

yum install -y epel-release && yum install -y stress-ngfi

#### **2.4.2 创建压力测试脚本**

bash

*\# 在 DPU 上创建 /root/dpu_stress_test/start_stress_test.sh# 脚本内容详见附件 1*

### **2.5 DC Cycle 主测试脚本**

#### **2.5.1 创建主测试脚本**

在 Host 上创建 ~/dpu_dc_cycle_test/scripts/dc_cycle_test.sh：

bash

\#!/bin/bash*\# 完整脚本内容详见附件 2*

#### **2.5.2 配置参数**

bash

*\# 修改脚本中的配置参数*DPU_IP="10.121.176.107"DPU_USER="root"DPU_PASSWORD="qwe!@#123"BMC_IP="10.121.177.209" *\# DPU BMC*BMC_USER="root"BMC_PASSWORD="0penBmc"CYCLE_COUNT=300 *\# DC Cycle 次数*MEMTEST_HOURS=1 *\# 每次测试时长*POWER_OFF_TIME=30 *\# 断电时间（秒）*

### **2.6 执行测试**

#### **2.6.1 启动测试**

bash

cd ~/dpu_dc_cycle_testchmod +x scripts/dc_cycle_test.sh

*\# 使用 tmux 运行*

tmux new-session -d -s dc_cycle_test "scripts/dc_cycle_test.sh"

#### **2.6.2 监控测试进度**

bash

*\# 查看日志*tail -f ~/dpu_dc_cycle_test/logs/dc_cycle_test\_\*.log

*\# 监控脚本*cat \> ~/monitor_dc_test.sh \<\< 'EOF'

\#!/bin/bash

while true; do

clear

echo "=== DPU DC Cycle 测试监控 ==="

echo "时间: \$(date)"

\# 监控逻辑...

done

EOF

### **2.7 测试验证**

#### **2.7.1 检查测试结果**

bash

*\# 汇总结果*cd ~/dpu_dc_cycle_testgrep -c "循环完成" logs/\*.loggrep -c "失败" logs/\*.log

#### **2.7.2 生成测试报告**

bash

*\# 创建报告生成脚本*cat \> generate_dc_report.sh \<\< 'EOF'

\#!/bin/bash

echo "=== DPU DC Cycle 测试报告 ==="

echo "生成时间: \$(date)"

\# 报告内容...

EOF

## **三、Warm Reboot 测试方案**

### **3.1 测试目标**

验证 Host 服务器反复重启过程中 DPU 的稳定性。

### **3.2 成功标准**

1.  

Host 服务器完成 300 次 Warm Reboot

2.  
3.  

测试过程中 Host 系统无死机、报错

4.  
5.  

DPU 始终运行未重启

6.  
7.  

所有压力测试正常运行

8.  
9.  

Host 每次启动都能正确识别 DPU 虚拟设备

10. 
11. 

DPU 网口数量显示正确

12. 
13. 

系统日志无告警、错误

14. 

### **3.3 准备工作**

#### **3.3.1 创建测试目录**

bash

mkdir -p ~/dpu_reboot_test/{scripts,logs,results}cd ~/dpu_reboot_test

#### **3.3.2 配置 SSH 免密登录**

bash

ssh-copy-id root@10.121.176.107 *\# DPU OS*

ssh-copy-id root@localhost *\# Host 自身*

#### **3.3.3 安装必要工具**

bash

yum install -y ipmitool expect pciutils net-tools tmux

### **3.4 DPU 压力测试部署**

#### **3.4.1 在 DPU 上部署压力测试**

bash

ssh root@10.121.176.107

*\# 创建压力测试目录*mkdir -p /root/dpu_stress_test

*\# 创建压力测试脚本 /root/dpu_stress_test/start_stress_test.sh# 脚本内容详见附件 3*

#### **3.4.2 启动 DPU 压力测试**

bash

*\# 在 DPU 上启动*

tmux new-session -d -s dpu_stress '/root/dpu_stress_test/start_stress_test.sh start'

### **3.5 Host Reboot 测试脚本**

#### **3.5.1 创建主测试脚本**

在 Host 上创建 ~/dpu_reboot_test/scripts/main_reboot_test.sh：

bash

\#!/bin/bash*\# 完整脚本内容详见附件 4*

#### **3.5.2 配置参数**

bash

*\# 修改脚本中的配置*HOST_IP="10.121.177.131"DPU_OS_IP="10.121.176.107"DPU_BMC_IP="10.121.177.209"HOST_BMC_IP="10.121.177.65"

BMC_USER="Administrator"BMC_PASSWORD="Admin@9000"DPU_BMC_USER="root"DPU_BMC_PASSWORD="0penBmc"DPU_OS_USER="root"DPU_OS_PASSWORD="qwe!@#123"

REBOOT_COUNT=300

### **3.6 执行测试**

#### **3.6.1 启动测试**

bash

cd ~/dpu_reboot_testchmod +x scripts/main_reboot_test.sh

*\# 使用启动脚本*

./start_test.sh

#### **3.6.2 监控测试**

bash

*\# 监控脚本*

./monitor_test.sh

*\# 查看实时日志*tail -f logs/reboot_test\_\*.log

### **3.7 测试验证**

#### **3.7.1 验证脚本**

bash

*\# 创建验证脚本*cat \> verify_results.sh \<\< 'EOF'

\#!/bin/bash

echo "=== DPU Reboot 测试结果验证 ==="

\# 验证逻辑...

EOF

chmod +x verify_results.sh

./verify_results.sh \> final_test_report.txt

#### **3.7.2 检查关键指标**

bash

*\# 1. 检查循环完成次数*ls results/cycle\_\*\_result.txt \| wc -l

*\# 2. 检查 DPU 状态*ssh root@10.121.176.107 "uptime; free -h"

*\# 3. 检查 Host DPU 设备*

lspci \| grep -i bluefieldip -br link show \| grep enp

*\# 4. 检查错误日志*grep -i "error\\fail" logs/\*.log \| tail -20

## **四、测试监控与维护**

### **4.1 实时监控命令**

#### **DC Cycle 测试监控：**

bash

*\# 查看测试进度*tail -f ~/dpu_dc_cycle_test/logs/dc_cycle_test\_\*.log

*\# 检查 DPU 状态*ssh root@10.121.176.107 "top -bn1 \| head -20"

*\# 检查温度*ssh root@10.121.176.107 "sensors 2\>/dev/null \|\| echo '无温度传感器'"

#### **Reboot 测试监控：**

bash

*\# 查看当前循环*cat ~/dpu_reboot_test/current_cycle.txt

*\# 监控 DPU 压力测试*ssh root@10.121.176.107 "/root/dpu_stress_test/start_stress_test.sh status"

*\# 检查网络设备*watch -n 10 "ip -br link show \| grep -c enp"

### **4.2 紧急处理**

#### **停止测试：**

bash

*\# 停止 DC Cycle 测试*pkill -f "dc_cycle_test.sh"ssh root@10.121.176.107 "pkill -f stress-ng"

*\# 停止 Reboot 测试*pkill -f "main_reboot_test.sh"sed -i '/continue_test.sh/d' /etc/rc.local

#### **恢复测试：**

bash

*\# 检查测试状态*cat ~/dpu_dc_cycle_test/logs/dc_cycle_test\_\*.log \| tail -20cat ~/dpu_reboot_test/current_cycle.txt

*\# 重新启动*cd ~/dpu_dc_cycle_test && ./scripts/dc_cycle_test.shcd ~/dpu_reboot_test && ./start_test.sh

### **4.3 日志收集**

bash

*\# 收集所有日志*tar -czf dpu_stability_test_logs\_\$(date +%Y%m%d).tar.gz \\

~/dpu_dc_cycle_test \\

~/dpu_reboot_test \\

/var/log/messages\* \\

/root/dpu_stress_test/logs 2\>/dev/null

## **五、测试报告模板**

### **5.1 DC Cycle 测试报告**

text

=== DPU DC Cycle 测试报告 ===

测试信息：

\- 测试时间：YYYY-MM-DD HH:MM:SS

\- 测试时长：XX 小时

\- DPU 型号：\[型号信息\]

\- Host 服务器：\[服务器信息\]

测试结果：

\- 总循环次数：300

\- 成功次数：XXX

\- 失败次数：XXX

\- 成功率：XX.XX%

详细结果：

1\. 内存测试稳定性：\[通过/失败\]

2\. 电源循环一致性：\[通过/失败\]

3\. 系统日志错误：\[0 个错误/XX 个错误\]

4\. DPU 恢复时间：\[平均 XX 秒\]

结论：

\[测试通过/测试失败\]

\[备注说明\]

### **5.2 Warm Reboot 测试报告**

text

=== Host Warm Reboot + DPU 稳定性测试报告 ===

测试信息：

\- 测试时间：YYYY-MM-DD HH:MM:SS

\- Host 服务器：10.121.177.131

\- DPU IP：10.121.176.107

\- 重启次数：300

测试结果：

\- 完成循环：XXX/300

\- DPU 运行时间：XXX 小时

\- 压力测试状态：\[正常/异常\]

\- 系统错误数：XXX

设备验证：

1\. DPU PCI 设备识别：\[正常/异常\]

2\. 网络接口数量：\[XX 个，符合预期\]

3\. 虚拟设备连接：\[正常/异常\]

4\. BMC 日志：\[无告警/有告警\]

性能数据：

\- DPU CPU 使用率：XX%

\- DPU 内存使用率：XX%

\- 网络带宽：\[正常/异常\]

结论：

\[测试通过/测试失败\]

\[建议和改进点\]

## **六、注意事项**

### **6.1 测试前检查**

1.  

确认所有设备网络连通

2.  
3.  

验证 SSH 免密登录配置

4.  
5.  

检查磁盘空间（至少预留 10GB 用于日志）

6.  
7.  

确认系统时间同步

8.  
9.  

备份重要数据

10. 

### **6.2 测试中监控**

1.  

定期检查日志文件大小

2.  
3.  

监控系统温度

4.  
5.  

检查网络连接状态

6.  
7.  

记录异常情况

8.  

### **6.3 测试后清理**

1.  

停止所有测试进程

2.  
3.  

清理临时文件

4.  
5.  

收集和备份日志

6.  
7.  

恢复系统配置

8.  

### **6.4 风险控制**

1.  

准备回退方案

2.  
3.  

确保有物理访问权限

4.  
5.  

准备备用电源

6.  
7.  

安排维护窗口

8.  

## **七、附录**

### **附件 1：DPU 压力测试脚本模板**

bash

\#!/bin/bash*\# DPU 压力测试脚本# 放置在 /root/dpu_stress_test/start_stress_test.sh*

LOG_DIR="/root/dpu_stress_test/logs"mkdir -p \$LOG_DIR

start_tests() {

*\# 启动 CPU 压力测试*

stress-ng --cpu \$((\$(nproc)\*4/5)) --timeout 0 &

*\# 启动内存压力测试*

TOTAL_MEM=\$(free -b \| grep Mem \| awk '{print \$2}')

TEST_MEM=\$((TOTAL_MEM \* 70 / 100 / 1024 / 1024))M

stress-ng --vm 2 --vm-bytes \$TEST_MEM --timeout 0 &

echo "压力测试已启动"}

*\# 根据参数执行*case "\$1" in

start) start_tests ;;

stop) pkill stress-ng ;;

status) ps aux \| grep stress-ng ;;esac

### **附件 2：紧急联系人**

| 角色       | 姓名     | 电话     | 邮箱     | 职责         |
|:-----------|:---------|:---------|:---------|:-------------|
| 测试负责人 | \[姓名\] | \[电话\] | \[邮箱\] | 整体测试协调 |
| 系统管理员 | \[姓名\] | \[电话\] | \[邮箱\] | 服务器维护   |
| 网络工程师 | \[姓名\] | \[电话\] | \[邮箱\] | 网络问题支持 |
| 硬件工程师 | \[姓名\] | \[电话\] | \[邮箱\] | DPU 硬件支持 |

## **文档修订记录**

| 版本 | 日期       | 修订内容     | 修订人   | 审核人   |
|:-----|:-----------|:-------------|:---------|:---------|
| 1.0  | 2024-01-05 | 初始版本     | \[姓名\] | \[姓名\] |
| 1.1  | 2024-01-10 | 增加监控章节 | \[姓名\] | \[姓名\] |
