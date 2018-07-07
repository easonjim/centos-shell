#!/bin/bash
#
# openvpn 2.4.6

# 安装依赖
yum install -y autoconf automake libtool gcc gcc-c++ make openssl openssl-devel pam-devel
# lzo
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
autoreconf -vi
./configure --prefix=/data/service/openvpn
make && make install

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
ExecStart=/usr/local/sbin/openvpn --daemon --writepid /var/run/openvpn/%i.pid --cd /etc/openvpn/ --config %i.conf

[Install]
WantedBy=multi-user.target
EOF