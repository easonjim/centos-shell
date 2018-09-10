#!/bin/bash
#
# node.js 8.11.2

# 解决相对路径问题
cd `dirname $0`

# 定义全局变量
NODE_URL=https://nodejs.org/dist/v8.11.2/node-v8.11.2-linux-x64.tar.xz
NODE_FILE=node-v8.11.2-linux-x64.tar.xz
NODE_FILE_PATH=node-v8.11.2-linux-x64
NODE_PATH=/data/service/node
NODE_PROFILE_D=/etc/profile.d/node.sh


# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 下载并解压
wget $NODE_URL -O $NODE_FILE && tar xvJf $NODE_FILE

# 移动
mv $NODE_FILE_PATH/* $NODE_PATH

# 设置环境变量
cat <<EOF > $NODE_PROFILE_D
export PATH=$NODE_PATH/bin:\$PATH
EOF

# 更新环境变量
. /etc/profile

# 安装PM2
npm install pm2 -g
