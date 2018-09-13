#!/bin/bash
#
# openvpn-admin自动安装脚本，使用原生安装不去除apache等组件

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
# 设置开机不启动
systemctl disable iptables
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

# 安装epel源
yum install -y wget
yum install -y epel-release
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# 配置remi源
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

# 安装依赖
yum install -y net-tools
# php5.6
yum remove -y php.x86_64 php-cli.x86_64 php-common.x86_64 php-gd.x86_64 php-ldap.x86_64 php-mbstring.x86_64 php-mcrypt.x86_64 php-mysql.x86_64 php-pdo.x86_64 
yum install -y --enablerepo=remi --enablerepo=remi-php56 php php-opcache php-devel php-mbstring php-mcrypt php-mysqlnd php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof
yum install -y --enablerepo=remi --enablerepo=remi-php56 php-fpm 
systemctl restart php-fpm
systemctl enable php-frm
# openvpn-admin
yum install -y openvpn httpd php php-mysql mariadb-server nodejs unzip git wget sed npm
npm install -g bower
systemctl enable mariadb
systemctl start mariadb

# 安装openvpn-admin
git clone https://github.com/Chocobozzz/OpenVPN-Admin openvpn-admin
cd openvpn-admin
./install.sh /var/www apache apache

# 配置数据库
cat <<EOF > /var/www/openvpn-admin/include/config.php
<?php
        \$host = 'localhost';
        \$port = '3306';
        \$db   = 'openvpn-admin';
        \$user = 'root';
        \$pass = '';
?>
EOF

# 配置apache
cp /etc/httpd/conf/httpd.conf{,.bak}
cat <<EOF > /etc/httpd/conf/httpd.conf
ServerRoot "/etc/httpd"
Listen 80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/openvpn-admin"
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/openvpn-admin">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html index.php
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType application/x-httpd-php-source .phps
    AddType application/x-httpd-php .php
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
EOF

# 启动apache
systemctl enable httpd
systemctl start httpd

# 启动openvpn
systemctl enable openvpn@server.service
systemctl start openvpn@server.service

# 最后访问
echo http://x.x.x.x/index.php?installation