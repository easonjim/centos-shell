#!/bin/bash
#
# config openvpn 2.4.6 and easy-rsa3 for centos7

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

CLIENT_NAME=$1
if [[ ! -n $1 ]]; then
  echo "请输入Client Name"
  exit 1
fi

if [ -d "/data/service/openvpn/easy-rsa-client/pki" ]; then
  echo "已经生成过pki，将删除后执行！"
  mv /data/service/openvpn/easy-rsa-client/pki /data/service/openvpn/easy-rsa-client/pki'_'`date +%Y%m%d_%H%M%S`
fi

cd /data/service/openvpn/easy-rsa-client
printf "\n################## Creating the certificates for client ##################\n"
./easyrsa init-pki 
./easyrsa gen-req ${CLIENT_NAME} nopass 
cd /data/service/openvpn/easy-rsa
./easyrsa import-req /data/service/openvpn/easy-rsa-client/pki/reqs/${CLIENT_NAME}.req ${CLIENT_NAME}
./easyrsa sign client ${CLIENT_NAME}
printf "\n################## Created the certificates for client ##################\n"
printf "\n################## 如下证书将被Client使用 ##################\n"
printf "/data/service/openvpn/easy-rsa/pki/ca.crt\n"
printf "/data/service/openvpn/easy-rsa/pki/issued/${CLIENT_NAME}.crt\n"
printf "/data/service/openvpn/easy-rsa-client/pki/private/${CLIENT_NAME}.key\n"
printf "/data/service/openvpn/easy-rsa/pki/ta.key\n"
printf "################## 如上证书将被Client使用 ##################\n"

if [ -d "/data/service/openvpn/${CLIENT_NAME}" ]; then
  mv /data/service/openvpn/${CLIENT_NAME} /data/service/openvpn/${CLIENT_NAME}'_'`date +%Y%m%d_%H%M%S`
fi
mkdir -p /data/service/openvpn/${CLIENT_NAME}
cp /data/service/openvpn/easy-rsa/pki/ca.crt /data/service/openvpn/${CLIENT_NAME}/
cp /data/service/openvpn/easy-rsa/pki/issued/${CLIENT_NAME}.crt /data/service/openvpn/${CLIENT_NAME}/
cp /data/service/openvpn/easy-rsa-client/pki/private/${CLIENT_NAME}.key /data/service/openvpn/${CLIENT_NAME}/
cp /data/service/openvpn/easy-rsa/pki/ta.key /data/service/openvpn/${CLIENT_NAME}/