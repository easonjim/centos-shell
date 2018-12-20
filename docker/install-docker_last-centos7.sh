#!/bin/bash
#
# docker最新版本，不支持CentOS 6

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 配置阿里云源
# 备份
cp /etc/yum.repos.d/CentOS-Base.repo{,.bak'_'`date +%Y%m%d_%H%M%S`}
# 下载
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# 生效测试
yum clean all
yum makecache

# 配置epel源
yum install -y epel-release
# 备份(如有配置其他epel源)
cp /etc/yum.repos.d/epel.rep{,.bak'_'`date +%Y%m%d_%H%M%S`}
cp /etc/yum.repos.d/epel-testing.repo{,.bak'_'`date +%Y%m%d_%H%M%S`}
# 下载新repo到/etc/yum.repos.d/
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# 卸载旧依赖
yum remove -y docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-selinux \
    docker-engine-selinux \
    docker-engine \
    docker-ce \
    docker-ce-cli

# 清除残留
mv /var/lib/docker{,.bak'_'`date +%Y%m%d_%H%M%S`}

# 安装Docker CE
# 设置存储库
yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2
yum-config-manager \
    --add-repo \
    http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum-config-manager --enable docker-ce-edge
# yum-config-manager --enable docker-ce-test
# yum-config-manager --disable docker-ce-edge
yum makecache fast
yum --enablerepo=base clean metadata
yum install -y docker-ce

# 创建用户组
groupadd docker
usermod -aG docker root
usermod -aG docker www-data

# 设置启动项
systemctl enable docker
service docker start

# 安装docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose