Host服务器 reboot、验证Host服务器在反复重启过程中DPU是否稳定运行、1.进入DPU OS，按照DPU整系统压力测试用例部署DPU压力。 2.Host服务器进入OS ，运行测试脚本warm reboot 300次，Host服务器每次进入OS监控DPU信息，如果正常则执行下一次Reboot，依次循环。reboot测试可以正常运行，测试过程中Host服务器系统无死机、报错等异常，DPU始终处于OS下未重启，所有压力正常运行，所有性能正常，Host服务器每次进入OS均可正确识别到所有DPU虚拟设备，DPU虚拟设备连接正常，DPU网口数量显示正确，整个测试过程Host或DPU系统日志以及Host BMC日志无告警、错误等异常日志产生。怎么测、主机BMC ip：10.121.177.65 Administrator Admin@9000 主机OSip：10.121.177.131 @qwer1234! DPU卡BMCip：10.121.177.209 root 0penBmc DPU卡OSip：10.121.176.107 root qwe!@#123

根据你的需求，我将设计一个完整的 **Host 服务器 Warm Reboot + DPU 稳定性测试** 方案。以下是详细步骤：

## **一、测试架构**

text

Host 服务器 (10.121.177.131)

│

├── BMC (10.121.177.65)

│

└── DPU (10.121.176.107)

│

└── DPU BMC (10.121.177.209)

## **二、准备工作**

### **1. 创建测试目录和日志结构**

bash

*\# 在 Host 服务器上创建*mkdir -p ~/dpu_reboot_test/{scripts,logs,results}cd ~/dpu_reboot_test

### **2. 配置 SSH 免密登录**

bash

*\# 生成 SSH 密钥（如果还没有）*

ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""

*\# 配置到 Host 自身的免密*

ssh-copy-id root@localhost

*\# 配置到 DPU OS*

ssh-copy-id root@10.121.176.107

*\# 测试连接*ssh root@10.121.176.107 "hostname"

### **3. 安装必要工具**

bash

*\# Host 服务器*

yum install -y ipmitool expect pciutils net-tools lm_sensors tmux*\# 或*apt install -y ipmitool expect pciutils net-tools lm-sensors tmux

## **三、DPU 压力测试部署**

### **1. DPU 压力测试脚本**

在 DPU (10.121.176.107) 上部署压力测试：

bash

*\# 登录 DPU*ssh root@10.121.176.107

*\# 创建压力测试目录*mkdir -p /root/dpu_stress_testcd /root/dpu_stress_test

*\# 创建压力测试脚本*cat \> /root/dpu_stress_test/start_stress_test.sh \<\< 'EOF'

\#!/bin/bash

\# DPU 压力测试脚本

\# 在 DPU OS 上运行

LOG_DIR="/root/dpu_stress_test/logs"

mkdir -p \$LOG_DIR

DATE=\$(date +%Y%m%d\_%H%M%S)

LOG_FILE="\$LOG_DIR/stress_test\_\${DATE}.log"

log() {

echo "\[\$(date '+%Y-%m-%d %H:%M:%S')\] \$1" \| tee -a \$LOG_FILE

}

\# 启动所有压力测试

start_tests() {

log "=== 启动 DPU 压力测试 ==="

log "DPU 主机名: \$(hostname)"

log "DPU IP: \$(hostname -I)"

log "开始时间: \$(date)"

\# 1. CPU 压力测试 (使用 80% CPU)

log "启动 CPU 压力测试..."

stress-ng --cpu \$((\$(nproc)\*4/5)) --timeout 0 --metrics-brief \> \$LOG_DIR/cpu_stress.log 2\>&1 &

CPU_PID=\$!

echo "CPU_PID=\$CPU_PID" \> /root/dpu_stress_test/pids.txt

\# 2. 内存压力测试 (使用 70% 内存)

log "启动内存压力测试..."

TOTAL_MEM=\$(free -b \| grep Mem \| awk '{print \$2}')

TEST_MEM=\$((TOTAL_MEM \* 70 / 100 / 1024 / 1024))M

stress-ng --vm 2 --vm-bytes \$TEST_MEM --timeout 0 \> \$LOG_DIR/mem_stress.log 2\>&1 &

MEM_PID=\$!

echo "MEM_PID=\$MEM_PID" \>\> /root/dpu_stress_test/pids.txt

\# 3. 网络压力测试

log "启动网络压力测试..."

\# 找到所有网络接口（排除 lo）

for iface in \$(ip link show \| grep -E "^\[0-9\]+:" \| grep -v lo \| awk -F: '{print \$2}' \| tr -d ' '); do

log "测试接口: \$iface"

\# 发送小包保持网络活跃

timeout 0 ping -I \$iface 127.0.0.1 \> /dev/null 2\>&1 &

done

\# 4. 磁盘 I/O 压力测试（如果有存储）

if df -h \| grep -q "/dev"; then

log "启动磁盘 I/O 测试..."

fio --name=random-write --ioengine=libaio --iodepth=4 --rw=randwrite \\

--bs=4k --direct=1 --size=100M --numjobs=2 --runtime=0 --time_based \\

--group_reporting \> \$LOG_DIR/disk_stress.log 2\>&1 &

DISK_PID=\$!

echo "DISK_PID=\$DISK_PID" \>\> /root/dpu_stress_test/pids.txt

fi

log "所有压力测试已启动"

log "当前系统状态:"

log "CPU 使用: \$(top -bn1 \| grep "Cpu(s)" \| awk '{print \$2}')%"

log "内存使用: \$(free -h \| grep Mem \| awk '{print \$3"/"\$2}')"

\# 监控进程

while true; do

if ! ps -p \$CPU_PID \> /dev/null 2\>&1; then

log "警告: CPU 压力测试进程终止，重新启动..."

stress-ng --cpu \$((\$(nproc)\*4/5)) --timeout 0 --metrics-brief \> \$LOG_DIR/cpu_stress.log 2\>&1 &

CPU_PID=\$!

fi

sleep 60

done

}

\# 停止所有测试

stop_tests() {

log "停止所有压力测试..."

if \[ -f /root/dpu_stress_test/pids.txt \]; then

while read line; do

eval \$line

kill -9 \$PID 2\>/dev/null

done \< /root/dpu_stress_test/pids.txt

fi

pkill -f stress-ng

pkill -f fio

log "压力测试已停止"

}

\# 检查测试状态

check_status() {

echo "=== DPU 压力测试状态 ==="

echo "时间: \$(date)"

echo "运行时间: \$(uptime)"

echo ""

echo "进程状态:"

ps aux \| grep -E "stress-ng\|fio" \| grep -v grep

echo ""

echo "系统负载:"

uptime

echo ""

echo "内存使用:"

free -h

echo ""

echo "网络接口:"

ip -br link show

echo ""

echo "日志尾部:"

tail -5 \$LOG_FILE 2\>/dev/null \|\| echo "无日志"

}

case "\$1" in

start)

start_tests

;;

stop)

stop_tests

;;

status)

check_status

;;

\*)

echo "用法: \$0 {start\|stop\|status}"

exit 1

;;

esac

EOF

*\# 给脚本执行权限*chmod +x /root/dpu_stress_test/start_stress_test.sh

*\# 安装压力测试工具*if command -v apt &\>/dev/null; then

apt update && apt install -y stress-ng fioelif command -v yum &\>/dev/null; then

yum install -y epel-release

yum install -y stress-ng fiofi

*\# 启动压力测试（在后台运行）*

tmux new-session -d -s dpu_stress '/root/dpu_stress_test/start_stress_test.sh start'

## **四、Host 服务器 Reboot 测试脚本**

### **1. 主测试脚本（在 Host 上运行）**

bash

*\# 在 Host 服务器上创建主脚本*cat \> ~/dpu_reboot_test/scripts/main_reboot_test.sh \<\< 'EOF'

\#!/bin/bash

\# Host 服务器 Warm Reboot + DPU 稳定性测试

\# 配置参数

HOST_IP="10.121.177.131"

DPU_OS_IP="10.121.176.107"

DPU_BMC_IP="10.121.177.209"

HOST_BMC_IP="10.121.177.65"

BMC_USER="Administrator"

BMC_PASSWORD="Admin@9000"

DPU_BMC_USER="root"

DPU_BMC_PASSWORD="0penBmc"

DPU_OS_USER="root"

DPU_OS_PASSWORD="qwe!@#123"

REBOOT_COUNT=300

TEST_DIR="/root/dpu_reboot_test"

LOG_DIR="\$TEST_DIR/logs"

RESULTS_DIR="\$TEST_DIR/results"

DATE=\$(date +%Y%m%d\_%H%M%S)

MAIN_LOG="\$LOG_DIR/reboot_test\_\${DATE}.log"

\# 创建目录

mkdir -p \$LOG_DIR \$RESULTS_DIR

\# 日志函数

log() {

echo "\[\$(date '+%Y-%m-%d %H:%M:%S')\] \$1" \| tee -a \$MAIN_LOG

}

\# 执行命令并记录

exec_cmd() {

log "执行: \$1"

eval \$1 2\>&1 \| tee -a \$MAIN_LOG

return \${PIPESTATUS\[0\]}

}

\# 等待 Host 启动完成

wait_for_host_boot() {

local timeout=300 \# 5分钟超时

local start_time=\$(date +%s)

log "等待 Host 启动..."

\# 等待网络可达

while \[ \$((\$(date +%s) - start_time)) -lt \$timeout \]; do

if ping -c 1 -W 2 \$HOST_IP &\>/dev/null; then

log "Host 网络已通"

\# 等待 SSH 服务

sleep 30

if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \\

\$HOST_IP "echo 'Host SSH连接成功'" &\>/dev/null; then

log "Host SSH 连接成功"

\# 等待系统完全启动

sleep 30

return 0

fi

fi

sleep 10

done

log "错误: Host 启动超时"

return 1

}

\# 检查 DPU 状态

check_dpu_status() {

local cycle=\$1

local check_log="\$LOG_DIR/dpu_check_cycle\_\${cycle}\_\${DATE}.log"

log "=== 第 \$cycle 次循环 - 检查 DPU 状态 ==="

\# 1. 检查 DPU OS 是否运行

if ! ping -c 3 -W 2 \$DPU_OS_IP &\>/dev/null; then

log "错误: DPU OS 不可达"

echo "DPU_OS_STATUS=FAILED" \> \$check_log

return 1

fi

\# 2. 检查 DPU 压力测试是否运行

ssh -o StrictHostKeyChecking=no \$DPU_OS_IP \<\< EOF 2\>&1 \| tee -a \$check_log

echo "=== DPU 状态检查 ==="

echo "时间: \\(date)"

echo "主机名: \\(hostname)"

echo "运行时间: \\(uptime)"

\# 检查压力测试进程

echo -e "\n=== 压力测试进程 ==="

if ps aux \| grep -E "stress-ng\|fio" \| grep -v grep; then

echo "DPU_STRESS_STATUS=RUNNING"

else

echo "DPU_STRESS_STATUS=STOPPED"

fi

\# 系统资源

echo -e "\n=== 系统资源 ==="

echo "CPU 使用:"

top -bn1 \| grep "Cpu(s)"

echo -e "\n内存使用:"

free -h

echo -e "\n负载:"

uptime

\# 检查系统日志错误

echo -e "\n=== 系统日志（最近错误）==="

dmesg \| tail -20 \| grep -i "error\\warn\\fail" \|\| echo "无错误日志"

\# 检查网络接口

echo -e "\n=== 网络接口 ==="

ip -br link show

ip -br addr show

\# 检查虚拟设备

echo -e "\n=== 虚拟设备 ==="

ls -la /dev/vfio/ 2\>/dev/null \|\| echo "无 vfio 设备"

EOF

local dpu_status=\$?

*\# 3. 检查 Host 是否能识别 DPU 设备*

log "检查 Host 的 DPU 设备..."

*\# 检查 PCI 设备*

echo -e "\n=== Host PCI 设备 ===" \| tee -a \$check_log

lspci -v \| grep -i "bluefield\\mellanox\\nvidia" \| tee -a \$check_log

*\# 检查网卡数量*

echo -e "\n=== Host 网络接口 ===" \| tee -a \$check_log

ip -br link show \| tee -a \$check_log

DPU_NICS=\$(ip -br link show \| grep -c "enp\\eth")

echo "检测到 \$DPU_NICS 个网络接口" \| tee -a \$check_log

*\# 检查虚拟设备*

echo -e "\n=== 虚拟设备连接 ===" \| tee -a \$check_log

ls -la /dev/vfio/ 2\>/dev/null \| tee -a \$check_log \|\| echo "无 vfio 设备" \| tee -a \$check_log

*\# 检查 BMC 日志*

echo -e "\n=== Host BMC 日志检查 ===" \| tee -a \$check_log

ipmitool -H \$HOST_BMC_IP -U \$BMC_USER -P \$BMC_PASSWORD sel list 2\>&1 \| tail -10 \| tee -a \$check_log

*\# 检查系统日志*

echo -e "\n=== Host 系统日志 ===" \| tee -a \$check_log

journalctl -n 20 --no-pager 2\>/dev/null \| grep -i "error\\warn\\fail" \| tee -a \$check_log \|\| echo "无错误日志" \| tee -a \$check_log

if \[ \$dpu_status -eq 0 \]; then

log "第 \$cycle 次 DPU 状态检查: PASS"

echo "DPU_CHECK_RESULT=PASS" \>\> \$check_log

return 0

else

log "第 \$cycle 次 DPU 状态检查: FAIL"

echo "DPU_CHECK_RESULT=FAIL" \>\> \$check_log

return 1

fi}

*\# 执行一次 reboot 循环*reboot_cycle() {

local cycle=\$1

log ""

log "\>\>\>\>\>\> 开始第 \$cycle/\$REBOOT_COUNT 次 Reboot 循环 \<\<\<\<\<\<"

*\# 1. 检查 DPU 状态（重启前）*

log "重启前检查 DPU 状态..."

if ! check_dpu_status "before\_\$cycle"; then

log "错误: 重启前 DPU 状态检查失败"

return 1

fi

*\# 2. 执行 Warm Reboot*

log "执行第 \$cycle 次 Warm Reboot..."

log "当前时间: \$(date)"

*\# 使用 systemctl reboot（正常重启）*

exec_cmd "sync"

exec_cmd "systemctl reboot"

*\# 脚本会在这里停止，等待系统重启*

*\# 重启后需要另一个脚本来继续执行*

return 0}

*\# 主监控函数（在重启后运行）*monitor_and_continue() {

local cycle=\$1

log "=== Host 重启完成，继续测试 ==="

*\# 等待系统完全启动*

wait_for_host_boot

*\# 检查 DPU 状态（重启后）*

log "重启后检查 DPU 状态..."

if ! check_dpu_status "after\_\$cycle"; then

log "错误: 重启后 DPU 状态检查失败"

return 1

fi

*\# 记录本次循环结果*

echo "CYCLE=\$cycle" \> \$RESULTS_DIR/cycle\_\${cycle}\_result.txt

echo "TIMESTAMP=\$(date)" \>\> \$RESULTS_DIR/cycle\_\${cycle}\_result.txt

echo "STATUS=PASS" \>\> \$RESULTS_DIR/cycle\_\${cycle}\_result.txt

log "第 \$cycle 次 Reboot 循环完成"

return 0}

*\# 主测试流程*main_test() {

log "=== DPU Reboot 稳定性测试开始 ==="

log "测试时间: \$(date)"

log "Host IP: \$HOST_IP"

log "DPU OS IP: \$DPU_OS_IP"

log "重启次数: \$REBOOT_COUNT"

log "日志目录: \$LOG_DIR"

*\# 初始状态检查*

log "执行初始状态检查..."

check_dpu_status "initial"

*\# 将启动脚本添加到启动项（用于重启后继续测试）*

setup_autostart

*\# 开始循环测试*

for ((current_cycle=1; current_cycle\<=\$REBOOT_COUNT; current_cycle++)); do

log "当前循环: \$current_cycle"

*\# 更新当前循环计数*

echo \$current_cycle \> \$TEST_DIR/current_cycle.txt

*\# 执行 reboot*

reboot_cycle \$current_cycle

*\# 这里不会执行到，因为 reboot 会终止进程*

done

log "测试完成!"}

*\# 设置自动启动（用于重启后继续测试）*setup_autostart() {

log "设置自动启动脚本..."

*\# 创建继续测试脚本*

cat \> /root/continue_test.sh \<\< 'CONTINUE_EOF'

\#!/bin/bash

\# 重启后继续测试脚本

TEST_DIR="/root/dpu_reboot_test"

LOG_DIR="\$TEST_DIR/logs"

DATE=\$(date +%Y%m%d\_%H%M%S)

\# 获取当前循环

if \[ -f \$TEST_DIR/current_cycle.txt \]; then

CURRENT_CYCLE=\$(cat \$TEST_DIR/current_cycle.txt)

else

CURRENT_CYCLE=1

fi

\# 等待网络

sleep 60

\# 执行监控

cd \$TEST_DIR/scripts

./main_reboot_test.sh monitor \$CURRENT_CYCLE 2\>&1 \| tee -a \$LOG_DIR/continue\_\${DATE}.log

\# 如果测试未完成，重启进行下一轮

if \[ \$CURRENT_CYCLE -lt \$(cat \$TEST_DIR/scripts/reboot_count.txt) \]; then

NEXT_CYCLE=\$((CURRENT_CYCLE + 1))

echo \$NEXT_CYCLE \> \$TEST_DIR/current_cycle.txt

sleep 10

systemctl reboot

fi

CONTINUE_EOF

chmod +x /root/continue_test.sh

*\# 添加到 rc.local（用于系统启动时执行）*

echo "/root/continue_test.sh &" \>\> /etc/rc.local

chmod +x /etc/rc.local

*\# 保存重启次数*

echo \$REBOOT_COUNT \> \$TEST_DIR/scripts/reboot_count.txt}

*\# 监控模式*monitor_mode() {

local cycle=\$1

log "进入监控模式，处理第 \$cycle 次循环"

monitor_and_continue \$cycle}

case "\$1" in

start)

main_test

;;

monitor)

if \[ -z "\$2" \]; then

echo "需要指定循环次数"

exit 1

fi

monitor_mode \$2

;;

status)

log "=== 测试状态 ==="

log "当前时间: \$(date)"

if \[ -f \$TEST_DIR/current_cycle.txt \]; then

log "当前循环: \$(cat \$TEST_DIR/current_cycle.txt)"

fi

log "日志文件: \$MAIN_LOG"

;;

\*)

echo "用法: \$0 {start\|monitor \<cycle\>\|status}"

exit 1

;;esac

EOF

chmod +x ~/dpu_reboot_test/scripts/main_reboot_test.sh

### **2. 创建简化版启动脚本**

bash

*\# 创建启动包装脚本*cat \> ~/dpu_reboot_test/start_test.sh \<\< 'EOF'

\#!/bin/bash

\# 启动 DPU Reboot 测试

TEST_DIR="/root/dpu_reboot_test"

SCRIPTS_DIR="\$TEST_DIR/scripts"

LOG_DIR="\$TEST_DIR/logs"

\# 确保在 tmux 中运行

if \[ -z "\$TMUX" \]; then

echo "在 tmux 中启动测试..."

tmux new-session -d -s reboot_test "\$SCRIPTS_DIR/main_reboot_test.sh start"

echo "测试已在 tmux 会话 'reboot_test' 中启动"

echo "查看日志: tail -f \$LOG_DIR/reboot_test\_\*.log"

echo "附加到会话: tmux attach -t reboot_test"

else

\$SCRIPTS_DIR/main_reboot_test.sh start

fi

EOF

chmod +x ~/dpu_reboot_test/start_test.sh

### **3. 创建监控脚本**

bash

cat \> ~/dpu_reboot_test/monitor_test.sh \<\< 'EOF'

\#!/bin/bash

\# 测试监控脚本

TEST_DIR="/root/dpu_reboot_test"

LOG_DIR="\$TEST_DIR/logs"

\# 查找最新日志

LATEST_LOG=\$(ls -t \$LOG_DIR/reboot_test\_\*.log 2\>/dev/null \| head -1)

if \[ -z "\$LATEST_LOG" \]; then

echo "未找到测试日志"

exit 1

fi

echo "=== DPU Reboot 测试监控 ==="

echo "时间: \$(date)"

echo "监控日志: \$(basename \$LATEST_LOG)"

echo ""

\# 显示测试进度

if \[ -f \$TEST_DIR/current_cycle.txt \]; then

CYCLE=\$(cat \$TEST_DIR/current_cycle.txt)

echo "当前循环: \$CYCLE/300"

echo "完成进度: \$((CYCLE\*100/300))%"

else

echo "测试可能未启动"

fi

echo ""

echo "=== 最近状态 ==="

tail -20 \$LATEST_LOG \| grep -E "开始\|完成\|检查\|错误"

echo ""

echo "=== DPU 当前状态 ==="

if ping -c 1 -W 2 10.121.176.107 &\>/dev/null; then

echo "DPU OS: 在线"

ssh root@10.121.176.107 "uptime" 2\>/dev/null \|\| echo "SSH 连接失败"

else

echo "DPU OS: 离线"

fi

echo ""

echo "=== Host DPU 设备 ==="

lspci \| grep -i "bluefield\\mellanox" \| wc -l \| xargs echo "DPU PCI 设备数量:"

echo ""

echo "按 Ctrl+C 退出监控"

echo "查看完整日志: tail -f \$LATEST_LOG"

EOF

chmod +x ~/dpu_reboot_test/monitor_test.sh

## **五、执行测试**

### **1. 启动测试**

bash

*\# 启动测试*cd ~/dpu_reboot_test

./start_test.sh

*\# 监控测试*

./monitor_test.sh

### **2. 实时监控**

bash

*\# 在另一个终端监控*ssh root@10.121.177.131

*\# 查看实时日志*tail -f ~/dpu_reboot_test/logs/reboot_test\_\*.log

*\# 监控 DPU 状态*watch -n 10 "ssh root@10.121.176.107 '/root/dpu_stress_test/start_stress_test.sh status'"

*\# 检查 Host DPU 设备*watch -n 10 "lspci \| grep -i bluefield; echo '网口数量:'; ip -br link show \| grep -c enp"

## **六、测试结果验证**

### **1. 验证脚本**

bash

cat \> ~/dpu_reboot_test/verify_results.sh \<\< 'EOF'

\#!/bin/bash

\# 测试结果验证脚本

TEST_DIR="/root/dpu_reboot_test"

LOG_DIR="\$TEST_DIR/logs"

RESULTS_DIR="\$TEST_DIR/results"

echo "=== DPU Reboot 测试结果验证 ==="

echo "验证时间: \$(date)"

echo ""

\# 1. 检查循环完成次数

COMPLETED_CYCLES=\$(ls \$RESULTS_DIR/cycle\_\*\_result.txt 2\>/dev/null \| wc -l)

echo "完成的循环次数: \$COMPLETED_CYCLES/300"

\# 2. 检查失败的循环

FAILED_CYCLES=\$(grep -l "STATUS=FAIL" \$RESULTS_DIR/\*.txt 2\>/dev/null \| wc -l)

echo "失败的循环次数: \$FAILED_CYCLES"

\# 3. 检查 DPU 压力测试状态

echo -e "\n=== DPU 压力测试状态 ==="

ssh root@10.121.176.107 \<\< 'DPU_EOF'

echo "DPU 运行时间: \$(uptime)"

echo "压力测试进程:"

ps aux \| grep -E "stress-ng\|fio" \| grep -v grep \| wc -l \| xargs echo "运行中的压力测试进程数:"

echo ""

echo "最近系统日志错误:"

dmesg \| tail -50 \| grep -i "error\\fail\\panic" \| tail -5 \|\| echo "无错误"

DPU_EOF

\# 4. 检查 Host DPU 设备

echo -e "\n=== Host DPU 设备 ==="

echo "PCI 设备:"

lspci \| grep -i "bluefield\\mellanox"

echo ""

echo "网络接口:"

ip -br link show \| grep enp

echo ""

echo "虚拟设备:"

ls -la /dev/vfio/ 2\>/dev/null \| wc -l \| xargs echo "VFIO 设备数量:"

\# 5. 检查日志错误

echo -e "\n=== 错误汇总 ==="

grep -i "错误\\error\\fail\\panic" \$LOG_DIR/\*.log \| tail -20

\# 6. 生成测试报告

echo -e "\n=== 测试总结 ==="

if \[ \$COMPLETED_CYCLES -eq 300 \] && \[ \$FAILED_CYCLES -eq 0 \]; then

echo "测试结果: PASS"

echo "所有 300 次 Reboot 循环完成"

echo "DPU 压力测试运行正常"

echo "无错误日志"

else

echo "测试结果: FAIL"

echo "请检查详细日志"

fi

EOF

chmod +x ~/dpu_reboot_test/verify_results.sh

### **2. 生成最终报告**

bash

*\# 测试完成后运行*cd ~/dpu_reboot_test

./verify_results.sh \> final_test_report.txt

*\# 查看报告*cat final_test_report.txt

## **七、注意事项**

### **1. 测试前检查**

bash

*\# 1. 确认所有 IP 可达*ping -c 2 10.121.177.131 *\# Host OS*ping -c 2 10.121.177.65 *\# Host BMC*ping -c 2 10.121.176.107 *\# DPU OS*ping -c 2 10.121.177.209 *\# DPU BMC*

*\# 2. 测试 SSH 连接*ssh root@10.121.176.107 "echo DPU连接测试成功"

*\# 3. 测试 BMC 连接*

ipmitool -H 10.121.177.65 -U Administrator -P Admin@9000 chassis status

### **2. 紧急停止**

bash

*\# 停止测试*pkill -f "main_reboot_test.sh"pkill -f "continue_test.sh"

*\# 停止 DPU 压力测试*ssh root@10.121.176.107 "/root/dpu_stress_test/start_stress_test.sh stop"

*\# 清除启动项*sed -i '/continue_test.sh/d' /etc/rc.local

### **3. 日志收集**

bash

*\# 收集所有日志*tar -czf dpu_reboot_test_logs\_\$(date +%Y%m%d).tar.gz \\

~/dpu_reboot_test/logs \\

~/dpu_reboot_test/results \\

/var/log/messages \\

/var/log/syslog \\

/root/dpu_stress_test/logs

这个完整的测试方案可以验证：

1.  

Host 服务器 300 次 Warm Reboot 的稳定性

2.  
3.  

DPU 在 Host 重启期间的持续运行能力

4.  
5.  

DPU 压力测试的稳定性

6.  
7.  

DPU 虚拟设备的正确识别

8.  
9.  

系统日志的完整性

10. 

测试过程中会自动记录所有状态，便于问题分析和结果验证。
