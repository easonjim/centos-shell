#!/bin/bash
# 设置hostname

# 检查是否为root用户，脚本必须在root权限下运行
source common/check-root.sh

# 设置hostname，并写入到文件
hostname $1 & hostname > /etc/hostname
