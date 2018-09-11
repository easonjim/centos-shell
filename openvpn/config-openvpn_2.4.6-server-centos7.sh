#!/bin/bash
#
# config openvpn 2.4.6 and easy-rsa3 for centos7
# 转发模式

cat <<EOF > /data/service/openvpn/server.conf
port 443
# 改成tcp，默认使用udp，如果使用HTTP Proxy，必须使用tcp协议
proto tcp
dev tun # 路由模式，桥接模式用dev tap
# 路径前面加keys，全路径为/etc/openvpn/keys/ca.crt
ca server/ca.crt
cert server/server.crt
key server/server.key  # This file should be kept secret
dh server/dh.pem
# 默认虚拟局域网网段，不要和实际的局域网冲突即可
server 10.8.0.0 255.255.255.0 # 路由模式，桥接模式用server-bridge
ifconfig-pool-persist ipp.txt
# 10.0.0.0/8是我这台VPN服务器所在的内网的网段，读者应该根据自身实际情况进行修改
push "route 10.0.0.0 255.0.0.0"
# 可以让客户端之间相互访问直接通过openvpn程序转发，根据需要设置
client-to-client
# 如果客户端都使用相同的证书和密钥连接VPN，一定要打开这个选项，否则每个证书只允许一个人连接VPN
duplicate-cn
keepalive 10 120
tls-auth server/ta.key 0 # This file is secret
comp-lzo
persist-key
persist-tun
# OpenVPN的状态日志，默认为/etc/openvpn/openvpn-status.log
status openvpn-status.log
# OpenVPN的运行日志，默认为/etc/openvpn/openvpn.log 
log-append openvpn.log
# 改成verb 5可以多查看一些调试信息
verb 5
EOF