#!/bin/bash
#
# config openvpn 2.4.6 and easy-rsa3 for centos7
# 吊销证书

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

cd /data/service/openvpn/easy-rsa

# 吊销证书
./easyrsa revoke ${CLIENT_NAME}
./easyrsa gen-crl
echo "证书吊销成功！请在server.conf增加此配置：crl-verify crl.pem"

# 备份原有文件
mv /data/service/openvpn/easy-rsa/pki/issued/${CLIENT_NAME}.crt /data/service/openvpn/easy-rsa/pki/issued/${CLIENT_NAME}.crt'_'`date +%Y%m%d_%H%M%S`
mv /data/service/openvpn/${CLIENT_NAME} /data/service/openvpn/${CLIENT_NAME}'_'`date +%Y%m%d_%H%M%S`