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

# 替换指定版本
# wget http://mirrors.jenkins.io/war-stable/2.138.3/jenkins.war -O jenkins.war
# mv /usr/lib/jenkins/jenkins.war{,.bak'_'`date +%Y%m%d_%H%M%S`}
# mv jenkins.war /usr/lib/jenkins/

# 迁移目录
# 创建目录
mkdir -p /data/service/jenkins
mkdir -p /data/service/jenkins/etc/init.d/
mkdir -p /data/service/jenkins/etc/logrotate.d/
mkdir -p /data/service/jenkins/etc/sysconfig/
mkdir -p /data/service/jenkins/usr/lib/jenkins/
mkdir -p /data/service/jenkins/usr/sbin/
mkdir -p /data/service/jenkins/var/cache/jenkins
mkdir -p /data/service/jenkins/var/lib/jenkins
mkdir -p /data/service/jenkins/var/log/jenkins

# 增加目录权限
chown -R jenkins:jenkins /data/service/jenkins/var/cache/jenkins
chown -R jenkins:jenkins /data/service/jenkins/var/lib/jenkins
chown -R jenkins:jenkins /data/service/jenkins/var/log/jenkins
usermod -aG www-data jenkins

# 迁移现有文件
mv /etc/init.d/jenkins /data/service/jenkins/etc/init.d/
mv /etc/logrotate.d/jenkins /data/service/jenkins/etc/logrotate.d/
mv /etc/sysconfig/jenkins /data/service/jenkins/etc/sysconfig/
mv /usr/lib/jenkins/jenkins.war /data/service/jenkins/usr/lib/jenkins/
mv /usr/sbin/rcjenkins /data/service/jenkins/usr/sbin/
mv /var/cache/jenkins{,_bak}
mv /var/lib/jenkins{,_bak}
mv /var/log/jenkins{,_bak}

# 创建现有文件为原来软链接
ln -s /data/service/jenkins/etc/init.d/jenkins /etc/init.d/jenkins
ln -s /data/service/jenkins/etc/logrotate.d/jenkins /etc/logrotate.d/jenkins
ln -s /data/service/jenkins/etc/sysconfig/jenkins /etc/sysconfig/jenkins
ln -s /data/service/jenkins/usr/lib/jenkins/jenkins.war /usr/lib/jenkins/jenkins.war
ln -s /data/service/jenkins/usr/sbin/rcjenkins /usr/sbin/rcjenkins
ln -s /data/service/jenkins/var/cache/jenkins /var/cache/jenkins
ln -s /data/service/jenkins/var/lib/jenkins /var/lib/jenkins
ln -s /data/service/jenkins/var/log/jenkins /var/log/jenkins