#!/bin/bash
#
# rsync 3.1.3

# 定义全局变量
RSYNC_URL=https://download.samba.org/pub/rsync/src/rsync-3.1.3.tar.gz
RSYNC_FILE=rsync-3.1.3.tar.gz
RSYNC_FILE_PATH=rsync-3.1.3
RSYNC_PATH=/data/service/rsync
RSYNC_PROFILE_D=/etc/profile.d/rsync.sh

# 检查是否为root用户，脚本必须在root权限下运行
source common/check-root.sh

# 下载并解压
wget $RSYNC_URL -O $RSYNC_FILE && tar zxvf $RSYNC_FILE

# 编译
cd $RSYNC_FILE_PATH
./configure --prefix=$RSYNC_PATH
make && make install

# 设置环境变量
cat <<EOF > $RSYNC_PROFILE_D
export PATH=$RSYNC_PATH/bin:\$PATH
EOF

# 更新环境变量
. /etc/profile
