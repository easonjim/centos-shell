#!/bin/bash
#
# pgpool2 4.7.3

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 定义全局变量
PGPOOL_URL=http://www.pgpool.net/download.php?f=pgpool-II-3.7.3.tar.gz
PGPOOL_FILE=pgpool-II-3.7.3.tar.gz
PGPOOL_FILE_PATH=pgpool-II-3.7.3
PGPOOL_PATH=/data/service/pgpool
PGPOOL_PROFILE_D=/etc/profile.d/pgpool.sh
POSTGRESQL_PATH=/data/service/postgresql
POSTGRESQL_USER=postgres

# 下载并解压
wget $PGPOOL_URL -O $PGPOOL_FILE && tar zxvf $PGPOOL_FILE

# 编译
mkdir -p $PGPOOL_PATH
cd $PGPOOL_FILE_PATH
./configure --prefix=$PGPOOL_PATH --with-pgsql=$POSTGRESQL_PATH
make && make install

# 设置用户变量
chown -R $POSTGRESQL_USER. $PGPOOL_PATH

# 设置环境变量
cat <<EOF > $PGPOOL_PROFILE_D
export PATH=$PGPOOL_PATH/bin:\$PATH
EOF

# 更新环境变量
export PATH=$PGPOOL_PATH/bin:$PATH
