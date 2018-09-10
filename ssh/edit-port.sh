#!/bin/bash
#
# 修改端口

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

readonly SSH_FILE_PATH='/etc/ssh/sshd_config'

# 备份
cp ${SSH_FILE_PATH}{,.bak}

# 开启22端口
sed -i 's/#Port 22/Port 22/g' ${SSH_FILE_PATH}
# 增加50022端口
port=50022
if [[ -n $1 ]]; then
  port=$1
fi
echo "Port ${port}" >> ${SSH_FILE_PATH}
# 重启sshd服务
service sshd reload