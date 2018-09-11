#!/bin/bash
#
# docker最新版本，不支持CentOS 6

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 卸载旧依赖
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine

# 安装Docker CE
# 设置存储库
yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
# yum-config-manager --enable docker-ce-test
# yum-config-manager --disable docker-ce-edge
yum install docker-ce

# 创建用户组
groupadd docker
usermod -aG docker root
usermod -aG docker www-data

# 设置启动项
systemctl enable docker