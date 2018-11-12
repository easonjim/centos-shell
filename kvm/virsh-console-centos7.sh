#!/bin/bash
#
# CentOS 7下设置使用virsh console登录KVM客户机

# 引入外部文件
source ../common/util.sh

# 检查root用户
util::check_root

systemctl enable serial-getty@ttyS0.service
systemctl start serial-getty@ttyS0.service

