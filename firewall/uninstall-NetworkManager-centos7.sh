#!/bin/bash
#
# CentOS 7 NetworkManager Uninstall

# 检查是否为root用户，脚本必须在root权限下运行
source common/check-root.sh

systemctl stop NetworkManager
systemctl disable NetworkManager
