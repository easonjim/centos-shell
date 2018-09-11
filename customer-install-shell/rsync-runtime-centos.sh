#!/bin/bash
#
# 应用运行环境-同步版，CentOS 7
# 注意：需要提前做ssh免密登录，并且使用www-data账号进行同步

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 同步安装环境
# java
# node
# ng
# rsync

# 设置文件夹权限隶属于www-data
