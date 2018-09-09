#!/bin/bash
#
# 设置www-data用户密码

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 设置密码
echo $1 | passwd --stdin www-data

# 清除历史
history -c
history -w