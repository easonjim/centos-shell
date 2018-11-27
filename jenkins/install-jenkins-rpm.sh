#!/bin/bash
#
# rpm install jenkins

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 安装依赖
wget http://pkg.jenkins-ci.org/redhat/jenkins-2.138-1.1.noarch.rpm -O jenkins-2.138-1.1.noarch.rpm 

# 安装jenkins
rpm -i jenkins-2.138-1.1.noarch.rpm 