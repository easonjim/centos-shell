#!/bin/bash
#
# config openvpn 2.4.6 and easy-rsa3 for centos7

IPADDR=$1
if [[ ! -n $1 ]]; then
  echo "请输入服务端IP"
  exit 1
fi

cat <<EOF > /data/service/openvpn/etc/client.conf
client
dev tun # 路由模式
# 改为tcp
proto tcp
# OpenVPN服务器的外网IP和端口
remote ${IPADDR} 51443
resolv-retry infinite
nobind
persist-key
persist-tun
ca client/ca.crt
# client1的证书
cert client/client.crt
# client1的密钥
key client/client.key
ns-cert-type server
# 去掉前面的注释
tls-auth client/ta.key 1
comp-lzo
verb 5
EOF