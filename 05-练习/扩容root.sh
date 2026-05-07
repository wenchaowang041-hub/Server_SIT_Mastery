#!/bin/bash
# 从 /home 分 1T 给 /root (LVM + ext4/xfs)
# 注意: 此脚本会清空 /home 数据，执行前请确认已备份

# 1. 备份 /home 数据
cp -a /home /home_backup

# 2. 卸载 /home
umount /home

# 3. 删除原有 home 逻辑卷
lvremove -f /dev/openeuler/home

# 4. 重新创建 home 卷 (原 7.2T，减去 1T 给 root，新建 6.2T)
lvcreate -L 6.2T -n home openeuler

# 5. 格式化为 xfs
mkfs.xfs /dev/openeuler/home

# 6. 挂载 /home
mount /dev/openeuler/home /home

# 7. 修复 fstab (确保文件系统类型正确)
sed -i 's|/dev/mapper/openeuler-home.*ext4|/dev/mapper/openeuler-home /home xfs defaults 0 0|' /etc/fstab

# 8. 扩容 root 逻辑卷到最大可用空间
lvextend -l +100%FREE /dev/openeuler/root

# 9. 在线扩容 root 文件系统 (ext4 用 resize2fs)
resize2fs /dev/openeuler/root

# 10. 恢复 /home 数据
cp -a /home_backup/* /home/

# 11. 清理备份
rm -rf /home_backup

# 12. 验证
df -h
