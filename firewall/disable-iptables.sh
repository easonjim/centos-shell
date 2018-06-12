#!/bin/bash
# 
# Disable iptables

# 检查是否为root用户，脚本必须在root权限下运行
source common/check-root.sh

# 清空所有默认规则
iptables -F
# 清空所有自定义规则
iptables -X
# 所有计数器归0
iptables -Z

# 停止服务
service iptables stop