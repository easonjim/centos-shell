#!/bin/bash
#
# mysql 5.7.18

# 安装依赖
yum install -y libaio

# 下载
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.18-linux-glibc2.5-x86_64.tar.gz -O mysql-5.7.18-linux-glibc2.5-x86_64.tar.gz

# 创建目录
mkdir -p /data/service/mysql

# 解压
tar zxvf mysql-5.7.18-linux-glibc2.5-x86_64.tar.gz
mv mysql-5.7.18-linux-glibc2.5-x86_64/* /data/service/mysql

# 创建用户组
groupadd mysql
useradd -g mysql -s /sbin/nologin mysql

# 修改权限
chown -R mysql:mysql /data/service/mysql

# 配置环境变量
cat <<EOF > /etc/profile.d/mysql.sh
export PATH=/data/service/mysql/bin:\$PATH
EOF
. /etc/profile

# 目录规划
# 数据datadir	/usr/local/mysql/data	
# 参数文件my.cnf	/usr/local/mysql/etc/my.cnf	
# 错误日志log-error	/usr/local/mysql/log/mysql_error.log	
# 二进制日志log-bin	/usr/local/mysql/binlogs/mysql-bin
# 慢查询日志slow_query_log_file	/usr/local/mysql/log/mysql_slow_query.log	
# 套接字socket文件	/usr/local/mysql/run/mysql.sock	
# pid文件	/usr/local/mysql/run/mysql.pid

mkdir -p /data/service/mysql/{binlogs,log,etc,run}
mkdir -p /data/database
ln -s /data/service/mysql /usr/local/mysql
ln -s /data/database    /usr/local/mysql/data
chown -R mysql.mysql /data/service/mysql/
chown -R mysql.mysql /usr/local/mysql/{data,binlogs,log,etc,run}

# 设置配置文件
rm -rf /etc/my.cnf
cat <<EOF > /usr/local/mysql/etc/my.cnf
[client]
port = 3306
socket = /usr/local/mysql/run/mysql.sock

[mysqld]
port = 3306
socket = /usr/local/mysql/run/mysql.sock
pid_file = /usr/local/mysql/run/mysql.pid
datadir = /usr/local/mysql/data
default_storage_engine = InnoDB
max_allowed_packet = 512M
max_connections = 2048
open_files_limit = 65535

skip-name-resolve
lower_case_table_names=1

character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'


innodb_buffer_pool_size = 1024M
innodb_log_file_size = 2048M
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit = 0


key_buffer_size = 64M

log-error = /usr/local/mysql/log/mysql_error.log
log-bin = /usr/local/mysql/binlogs/mysql-bin
slow_query_log = 1
slow_query_log_file = /usr/local/mysql/log/mysql_slow_query.log
long_query_time = 5


tmp_table_size = 32M
max_heap_table_size = 32M
query_cache_type = 0
query_cache_size = 0

server-id=1
EOF

# 初始化
mysqld --initialize --user=mysql --datadir=/data/database --basedir=/data/service/mysql
# 此时会输出临时密码，一定要记住
echo "请记住这个临时root密码！！！"

# 生成ssl
mysql_ssl_rsa_setup --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data/

# 设置启动项目
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql.server
chkconfig --add mysql.server
chkconfig  mysql.server on
# 启动
service mysql.server start

# 重置root密码
echo "请输入root新密码:"
mysql_secure_installation

# 导入时区
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p mysql

# 设置用户隶属于www-data用户组
usermod -aG www-data mysql