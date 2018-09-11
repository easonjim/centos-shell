#!/bin/bash
#
# 应用运行环境-安装版，CentOS 7

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 安装环境
# java
base ../java/install-java_1.8.0_172.sh
base ../java/install-maven_3.5.3.sh
base ../tomcat/install-tomcat_8.5.31.sh
# node
base ../node/install-node_8.11.2.sh
# ng
base ../nginx/install-nginx_1.14.0.sh
# rsync
base ../rsync/install-rsync_3.1.3.sh
# docker
base ../docker/install-docker_last-centos7.sh

# 设置文件夹权限隶属于www-data
base ../directory/set-dirgroup-www-data.sh