# 1. 一键安装（配置 rc.local）
sudo bash setup.sh

# 2. 开始测试
python3 /opt/dc_cycle/dc_cycle.py --start --cycles 100

# 3. 服务器开始自动 power cycle，每次开机 rc.local 自动继续

# 4. 随时查看进度
python3 /opt/dc_cycle/dc_cycle.py --status

# 5. 提前停止
python3 /opt/dc_cycle/dc_cycle.py --stop
```

---

## 工作原理
```
--start
  └─▶ 写入 state.json（next=1, total=100）
  └─▶ ipmitool chassis power cycle → 服务器断电重启

开机后 rc.local
  └─▶ dc_cycle.py --auto
        ├─▶ 等待 90s（系统稳定）
        ├─▶ 健康检查（磁盘/内存/电源状态）→ 记录 PASS/FAIL
        ├─▶ 写入 next+1 到 state.json
        └─▶ ipmitool chassis power cycle → 下一次