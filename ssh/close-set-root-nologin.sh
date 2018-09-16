#!/bin/bash
#
# 关闭-设置root用户不能远程登录

# 解决相对路径问题
cd `dirname $0`

# 引入外部文件
source ../common/util.sh

# 检查root
util::check_root

# 定义变量
readonly SSH_FILE_PATH='/etc/ssh/sshd_config'

# 备份
cp ${SSH_FILE_PATH}{,.bak'_'`date +%Y%m%d_%H%M%S`}

# 禁止root远程登录
sed -i 's/PermitRootLogin no/#PermitRootLogin no/g' ${SSH_FILE_PATH}
sed -i 's/PermitEmptyPasswords no/#PermitEmptyPasswords no/g' ${SSH_FILE_PATH}
sed -i 's/UseDNS no/#UseDNS no/g' ${SSH_FILE_PATH}

# 从新加载配置
service sshd reload 

