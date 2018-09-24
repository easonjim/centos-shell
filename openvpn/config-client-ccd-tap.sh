#!/bin/bash
#
# 配置ccd客户端路由和IP

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 定义变量
CLIENT_NAME=$1

if [[ ! -n $1 ]]; then
  echo "请输入Client Name"
  exit 1
fi


# ccd
mkdir -p /data/service/openvpn/etc/ccd
cat << EOF > /data/service/openvpn/etc/${CLIENT_NAME}

EOF