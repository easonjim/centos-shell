#!/bin/bash
#
# config openvpn 2.4.6 and easy-rsa3 for centos7

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

if [ -d "/data/service/openvpn/easy-rsa/pki" ]; then
  echo "已经生成过pki，将删除后执行！"
  mv /data/service/openvpn/easy-rsa/pki /data/service/openvpn/easy-rsa/pki'_'`date +%Y%m%d_%H%M%S`
fi

cd /data/service/openvpn/easy-rsa

printf "\n################## Creating the certificates for server ##################\n"
./easyrsa init-pki 
./easyrsa build-ca 
./easyrsa gen-req server nopass 
./easyrsa sign server server 
./easyrsa gen-dh

cd ../sbin
./openvpn --genkey --secret /data/service/openvpn/easy-rsa/pki/ta.key
printf "\n################## Created the certificates for server ##################\n"
printf "\n################## 如下证书将被Server使用 ##################\n"
printf "/data/service/openvpn/easy-rsa/pki/ca.crt\n"
printf "/data/service/openvpn/easy-rsa/pki/private/server.key\n"
printf "/data/service/openvpn/easy-rsa/pki/issued/server.crt\n"
printf "/data/service/openvpn/easy-rsa/pki/dh.pem\n"
printf "/data/service/openvpn/easy-rsa/pki/ta.key\n"
printf "################## 如上证书将被Server使用 ##################\n"

if [ -d "/data/service/openvpn/server" ]; then
  mv /data/service/openvpn/server /data/service/openvpn/server'_'`date +%Y%m%d_%H%M%S`
fi
mkdir -p /data/service/openvpn/server
cp /data/service/openvpn/easy-rsa/pki/ca.crt /data/service/openvpn/server/
cp /data/service/openvpn/easy-rsa/pki/private/server.key /data/service/openvpn/server/
cp /data/service/openvpn/easy-rsa/pki/issued/server.crt /data/service/openvpn/server/
cp /data/service/openvpn/easy-rsa/pki/dh.pem /data/service/openvpn/server/
cp /data/service/openvpn/easy-rsa/pki/ta.key /data/service/openvpn/server/