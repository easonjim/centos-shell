#!/bin/bash
#
# install openvpn 2.4.6 and easy-rsa3 for centos7

# 关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
# 生效命令
setenforce 0

# 安装epel源
yum install -y wget
yum install -y epel-release
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

# 开启路由转发功能
sed -i '/net.ipv4.ip_forward/s/0/1/' /etc/sysctl.conf
sysctl -p

# 关闭防火墙
# 根据系统版本判断
if [[ `rpm -q centos-release|cut -d- -f3` = 6 ]]
    then
        echo "CentOS 6不支持！"
        exit 1
    else
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
    fi

# 安装编译依赖
yum install -y autoconf automake libtool gcc gcc-c++ make net-tools
# 安装openvpn编译专属依赖
yum install -y openssl openssl-devel pam-devel
# lzo用于压缩通讯数据加快传输速度
wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz
tar -zxvf lzo-2.10.tar.gz
cd lzo-2.10
./configure --prefix=/usr/local/ 
make && make install
cd ..

# 下载并解压openvpn
wget https://github.com/OpenVPN/openvpn/archive/v2.4.6.tar.gz -O openvpn-2.4.6.tar.gz --no-check-certificate
tar -zxvf openvpn-2.4.6.tar.gz
cd openvpn-2.4.6

# 编译openvpn
mkdir /data/service/openvpn -p
autoreconf -vi
./configure --prefix=/data/service/openvpn
make && make install
# 创建openvpn配置文件放置文件夹
mkdir /data/service/openvpn/etc -p
mkdir -p /data/service/openvpn/share/sample
cp -rf sample/sample-*  /data/service/openvpn/share/sample/
cd ..

# 配置环境变量
cat <<EOF > /etc/profile.d/openvpn.sh
export PATH=/data/service/openvpn/sbin:\$PATH
EOF

# 配置开机启动服务
mkdir -p /var/run/openvpn
cat <<EOF > /usr/lib/systemd/system/openvpn@.service
[Unit]
Description=OpenVPN Robust And Highly Flexible Tunneling Application On %I
After=network.target

[Service]
PrivateTmp=true
Type=forking
PIDFile=/var/run/openvpn_%i.pid
ExecStart=/data/service/openvpn/sbin/openvpn --daemon --writepid /var/run/openvpn_%i.pid --cd /data/service/openvpn/etc --config %i.conf

[Install]
WantedBy=multi-user.target
EOF
# 设置执行权限
chmod +x /usr/lib/systemd/system/openvpn@.service
# 设置开机启动（根据实际情况替换server参数）
# systemctl enable openvpn@server.service

# 创建pid文件夹
mkdir -p /var/run/openvpn

# 更新环境变量
. /etc/profile

# 安装运行依赖
# easy-rsa 3
wget https://github.com/OpenVPN/easy-rsa/archive/v3.0.4.tar.gz -O easy-rsa-3.0.4.tar.gz --no-check-certificate
tar -zxvf easy-rsa-3.0.4.tar.gz
cd easy-rsa-3.0.4
# easy-rsa不用编译，直接拷贝使用即可
mkdir -p /data/service/openvpn/easy-rsa
cp -rf easyrsa3/* /data/service/openvpn/easy-rsa
mkdir -p /data/service/openvpn/easy-rsa-client
cp -rf easyrsa3/* /data/service/openvpn/easy-rsa-client

# 安装后初始化
mkdir -p /data/service/openvpn/etc/ccd
# 目录规划
# 目的是为了和yum安装的保持一致
ln -s /data/service/openvpn /etc/openvpn
# 安装网桥工具依赖
yum install -y bridge-utils