#!/bin/bash
#
# mysql 5.7.x

wget -O https://cdn.mysql.com/Downloads/MySQL-5.7/mysql-5.7.23-el7-x86_64.tar.gz mysql-5.7.23-el7-x86_64.tar.gz

groupadd mysql
useradd -r -g mysql mysql

mkdir -p /data/service/mysql
mkdir -p /data/database

tar zxvf mysql-5.7.23-el7-x86_64.tar.gz
mv mysql-5.7.23-el7-x86_64 /data/service/mysql

chown -R mysql:mysql /data/service/mysql
chown -R mysql:mysql /data/database

# 配置环境变量
cat <<EOF > /etc/profile.d/mysql.sh
export PATH=/data/service/mysql/bin:\$PATH
EOF
. /etc/profile

# 初始化
mysqld --initialize --user=mysql --datadir=/data/database --basedir=/data/service/mysql

cp /data/service/mysql/support-files/my-default.cnf /etc/my.cnf

cat <<EOF > /etc/my.cnf
[mysqld]
basedir = /data/service/mysql
datadir = /data/database
port = 3306
socket = /data/service/mysql/tmp/mysql.sock
 
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
EOF

# 开机启动
cp /data/service/mysql/support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
chkconfig --add mysql