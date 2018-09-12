#!/bin/bash
#
# 初始化user用户组，普通用户组

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 设置sudogroup用户组
echo "设置普通用户组为usergroup"
if [[ `grep -c "^userroup" /etc/passwd` = 0 || `grep -c "^usergroup" /etc/group` = 0 ]]; then
    useradd usergroup
else
    echo "usergroup用户已存在"
fi
