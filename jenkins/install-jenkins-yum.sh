#!/bin/bash
#
# yum install jenkins

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 安装依赖
yum install -y epel-release
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# 安装jenkins
yum install jenkins

# 替换指定版本
# wget http://mirrors.jenkins.io/war-stable/2.138.3/jenkins.war -O jenkins.war
# mv /usr/lib/jenkins/jenkins.war{,.bak'_'`date +%Y%m%d_%H%M%S`}
# mv jenkins.war /usr/lib/jenkins/