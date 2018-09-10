#!/bin/bash
#
# 初始化新用户，普通用户组

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 初始化usergroup
bash init-usergroup.sh
# 增加用户
bash add-user.sh $1 $2

# 清除历史记录
history -c
history -w