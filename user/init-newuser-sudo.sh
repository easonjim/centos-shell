#!/bin/bash
#
# 初始化新用户，并加入到sudo权限组下，以这份为入口

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 初始化sudogroup
bash init-sudogroup.sh
# 增加用户
bash add-user.sh $1 $2
# 设置sudo权限
bash set-user-sudo.sh $1

# 清除历史记录
history -c
history -w