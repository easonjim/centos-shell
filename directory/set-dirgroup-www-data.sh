#!/bin/bash
#
# 设置data文件夹用户组为www-data

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 设置用户组
chown -R www-data:www-data /data
# 增删改权限
chmod -R 770 /data