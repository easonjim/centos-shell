#!/bin/bash
#
# webvirtmgr

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
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config   #修改配置文件则永久生效，但是必须要重启系统。
# 生效命令
setenforce 0

# 设置目录并安装nginx
echo "请确定已经设置好目录(/data/service)：mkdir -p /data/service"

# 安装kvm（这一步不要求按照这个，只需要安装成功即可）
echo "请确定已经安装好KVM"

# 安装WebVirtMgr依赖
yum install epel-release
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
# 这一步的epel源是关键，如果安装不成功，那么下面的依赖也会安装不成功
yum -y install git python-pip libvirt-python libxml2-python python-websockify supervisor
yum -y install gcc python-devel
pip install numpy

# 正式安装WebVirtMgr并配置超级登录用户
cd /data/service
git clone git://github.com/retspen/webvirtmgr.git
cd webvirtmgr
pip install -r requirements.txt
./manage.py syncdb
# 配置超级用户
./manage.py collectstatic

# 设置nginx
cat <<EOF > /data/service/nginx_vhost/webvirtmgr.conf
server {
    listen 8001;

    server_name \$hostname;
    access_log /data/weblog/nginx/webvirtmgr_access_log;

    location /static/ {
        root /data/service/webvirtmgr/webvirtmgr;
        expires max;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-for \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host:\$server_port;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        client_max_body_size 1024M;
    }
}
EOF

# 重启nginx
service nginx restart
# 配置supervisord服务
# 设置权限
chown -R nginx:nginx /data/service/webvirtmgr
# 其实是在supervisord服务增加webvirtmgr进程的启动，依赖这个服务而已。

# 开机自启
systemctl enable supervisord

# 增加进程启动配置
cat <<EOF > /etc/supervisord.d/webvirtmgr.ini
[program:webvirtmgr]
command=/usr/bin/python /data/service/webvirtmgr/manage.py run_gunicorn -c /data/service/webvirtmgr/conf/gunicorn.conf.py
directory=/data/service/webvirtmgr
autostart=true
autorestart=true
logfile=/var/log/supervisor/webvirtmgr.log
log_stderr=true
user=nginx

[program:webvirtmgr-console]
command=/usr/bin/python /data/service/webvirtmgr/console/webvirtmgr-console
directory=/data/service/webvirtmgr
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/webvirtmgr-console.log
redirect_stderr=true
user=nginx
EOF
# 重启服务
service supervisord restart

# 权限设置（重点），也是设置Local登录的一种方式
# 增加权限组
groupadd libvirtd
# 增加用户到权限组
usermod -a -G libvirtd root
usermod -a -G libvirtd nginx
# 设置kvm服务libvirtd启动权限
sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirtd"/g' /etc/libvirt/libvirtd.conf

# 增加权限启动配置
cat <<EOF > /etc/polkit-1/localauthority/50-local.d/50-org.libvirtd-group-access.pkla
[libvirtd group Management Access]
Identity=unix-group:libvirtd
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF

# 最后重启服务
service libvirtd restart
service supervisord start

echo "请勿设置为其它用户组权限/data/service/webvirtmgr，请一定保证为nginx用户组"
echo "如果/data/service/webvirtmgr的顶层权限不是nginx用户组，那么请设置nginx隶属于这个用户组，比如顶层权限为www-data用户组时：usermod -a -G www-data nginx"
