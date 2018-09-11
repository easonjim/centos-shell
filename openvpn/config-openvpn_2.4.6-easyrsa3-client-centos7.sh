#!/bin/bash
#
# config openvpn 2.4.6 and easy-rsa3 for centos7

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

cd /data/service/openvpn/easy-rsa-client

printf "\n################## Creating the certificates for client ##################\n"
./easyrsa init-pki 
./easyrsa gen-req client nopass 
/data/service/openvpn/easy-rsa/easyrsa import-req /data/service/openvpn/easy-rsa-client/pki/reqs/client.req client
/data/service/openvpn/easy-rsa/easyrsa sign client client

printf "\n################## Created the certificates for client ##################\n"
printf "\n################## 如下证书将被Client使用 ##################\n"
printf "/data/service/openvpn/easy-rsa/pki/ca.crt\n"
printf "/data/service/openvpn/easy-rsa/pki/issued/client.crt\n"
printf "/data/service/openvpn/easy-rsa-client/pki/private/client.key\n"
printf "/data/service/openvpn/easy-rsa/pki/ta.key\n"
printf "################## 如上证书将被Client使用 ##################\n"

mkdir -p /data/service/openvpn/client
cp /data/service/openvpn/easy-rsa/pki/ca.crt /data/service/openvpn/client/
cp /data/service/openvpn/easy-rsa/pki/issued/client.crt /data/service/openvpn/client/
cp /data/service/openvpn/easy-rsa-client/pki/private/client.key /data/service/openvpn/client/
cp /data/service/openvpn/easy-rsa/pki/ta.key /data/service/openvpn/client/