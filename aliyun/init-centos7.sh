#!/bin/sh
#
# aliyun init for centos7

# 引入外部文件
source ../common/util.sh

# 检查root
util::check_root

# 定义变量
readonly SSH_FILE_PATH='/etc/ssh/sshd_config'

# 设置SSH断线超时
sed -i 's/#ClientAliveInterval/ClientAliveInterval/g' ${SSH_FILE_PATH}
sed -i 's/#ClientAliveCountMax/ClientAliveCountMax/g' ${SSH_FILE_PATH}
sed -i 's/ClientAliveInterval 0/ClientAliveInterval 30/g' ${SSH_FILE_PATH}
sed -i 's/ClientAliveCountMax 3/ClientAliveCountMax 120/g' ${SSH_FILE_PATH}
# 重启sshd
service sshd restart