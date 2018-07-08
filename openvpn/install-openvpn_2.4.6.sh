#!/bin/bash
#
# openvpn 2.4.6

# 安装编译依赖
yum install -y autoconf automake libtool gcc gcc-c++ make 
# 安装openvpn专属依赖
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
cat <<EOF > /usr/lib/systemd/system/openvpn.service
[Unit]
Description=OpenVPN Robust And Highly Flexible Tunneling Application On %I
After=network.target

[Service]
PrivateTmp=true
Type=forking
PIDFile=/var/run/openvpn/%i.pid
ExecStart=/data/service/openvpn/sbin/openvpn --daemon --writepid /var/run/openvpn/%i.pid --cd /data/service/openvpn/etc --config %i.conf

[Install]
WantedBy=multi-user.target
EOF
# 设置执行权限
chmod +x /usr/lib/systemd/system/openvpn.service
# 设置开机启动
systemctl enable openvpn

# 更新环境变量
. /etc/profile

# 安装运行依赖
# easy-rsa 3
wget https://github.com/OpenVPN/easy-rsa/archive/v3.0.4.tar.gz -O easy-rsa-3.0.4.tar.gz --no-check-certificate
tar -zxvf easy-rsa-3.0.4.tar.gz
cd easy-rsa-3.0.4
mkdir -p /data/service/openvpn/