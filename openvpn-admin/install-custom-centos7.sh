#!/bin/bash
#
# openvpn-admin自定义安装脚本
# 不安装php、apache、mysql，因此需要自行安装
# 运行前，请修改mysql登录密码

# 卸载网络组件
systemctl stop NetworkManager
systemctl disable NetworkManager
# 关闭默认防火墙
systemctl stop firewalld.service 
systemctl disable firewalld.service 
# 安装iptables
yum install -y iptables
# 升级iptables
yum update iptables 
# 安装iptables-services
yum install -y iptables-services
# 设置开机启动
systemctl enable iptables
# 启动
systemctl start iptables
# 清空所有默认规则
iptables -F
# 清空所有自定义规则
iptables -X
# 所有计数器归0
iptables -Z
# 停止服务
service iptables stop   

# 关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
# 生效命令
setenforce 0

# 安装顶层依赖
# php
if command -v php >/dev/null 2>&1; then 
  echo 'exists php' 
else 
  echo 'no exists php' 
  bash ../php/install-php_7.1.21.sh
fi
# nginx
if command -v nginx >/dev/null 2>&1; then 
  echo 'exists nginx' 
else 
  echo 'no exists nginx' 
  bash ../nginx/install-nginx_1.14.0.sh
fi
# mysql
if command -v mysqld >/dev/null 2>&1; then 
  echo 'exists mysql' 
else 
  echo 'no exists mysql' 
  bash ../nginx/install-mysql_5.7.18.sh
fi

# openvpn-admin
yum install -y nodejs unzip git wget sed npm
npm install -g bower

# 安装openvpn-admin
git clone https://github.com/Chocobozzz/OpenVPN-Admin openvpn-admin
cd openvpn-admin
./install.sh /var/www nginx nginx

# 配置数据库
echo "请配置数据库连接：/var/www/openvpn-admin/include/config.php"

# 配置nginx
echo "请配置nginx"

# 启动openvpn
echo "请启动openvpn"

# 最后访问
echo "请访问完成最后安装：http://x.x.x.x/index.php?installation"