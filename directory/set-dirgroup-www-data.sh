#!/bin/bash
#
# 设置data文件夹用户组为www-data

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

DIR_PATH=$1
if [[ ! -n $1 ]]; then
  export DIR_PATH="/data"
  exit 1
fi

# 设置用户组
chown -R www-data:www-data ${DIR_PATH}
# 增删改权限
chmod -R 770 ${DIR_PATH}