#!/bin/bash
#
# rsync 3.1.3

# 解决相对路径问题
cd `dirname $0`

# 定义全局变量
RSYNC_URL=https://download.samba.org/pub/rsync/src/rsync-3.1.3.tar.gz
RSYNC_FILE=rsync-3.1.3.tar.gz
RSYNC_FILE_PATH=rsync-3.1.3
RSYNC_PATH=/data/service/rsync
RSYNC_PROFILE_D=/etc/profile.d/rsync.sh

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

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

# 去除系统默认rsync
mv /usr/bin/rsync{,.bak'_'`date +%Y%m%d_%H%M%S`}

# 增加远程sudo执行，依赖www-data用户，用于sudo远程同步时权限提升
if [[ `grep -c "^www-data" /etc/sudoers` = 0 ]]; then
    # 增加sudo权限用于rsync
    echo "www-data    ALL=NOPASSWD:/data/service/rsync/bin/rsync" >> /etc/sudoers
else
    echo "www-data用户的sudo执行rsync权限已存在"
fi