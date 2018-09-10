#!/bin/bash
#
# 初始化sudo用户组

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
bash ../common/util.sh
util::check_root

# 设置sudogroup用户组
if [[ `grep -c "^sudogroup" /etc/passwd` = 0 || `grep -c "^sudogroup" /etc/group` = 0 ]]; then
    useradd sudogroup
    # 设置sudo权限
    echo "%sudogroup    ALL=(ALL)       ALL" >> /etc/sudoers
else
    echo "sudogroup用户已存在"
fi