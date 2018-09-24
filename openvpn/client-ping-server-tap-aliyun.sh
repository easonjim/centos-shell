#!/bin/bash
#
# 定时ping服务器，使用内网IP，阿里云VPC的BUG
# 原因：阿里云VPC默认网关253导致非阿里云ECS服务器使用网桥时无法实现Server ping Client，而Client可以ping Server，但只要Client ping Server之后，立刻Server即可ping通Client。
# 导致以上的原因是VPC默认网关优先返回，即使arp已经正确回包，但更新的MAC地址都是来自VPC默认网关的MAC

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 定义变量
SERVER_IP=$1
if [[ ! -n $1 ]]; then
  echo "请输入Server VPN内网IP"
  exit 1
fi

# ping
cat << EOF > /data/service/openvpn/etc/client_ping_server_tap_aliyun.sh
ping ${SERVER_IP} -c 4
EOF
chmod +x /data/service/openvpn/etc/client_ping_server_tap_aliyun.sh

## 写入定时任务
if [[ `grep -c "client_ping_server_tap_aliyun" /etc/crontab` = 0 ]]; then
    echo '*/1 * * * * root bash /data/service/openvpn/etc/client_ping_server_tap_aliyun.sh &>/dev/null' >> /etc/crontab
fi