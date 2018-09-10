#!/bin/bash
#
# maven 3.5.3

# 解决相对路径问题
cd `dirname $0`

# 定义全局变量
MAVEN_URL=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.5.3/apache-maven-3.5.3-bin.tar.gz
MAVEN_FILE=apache-maven-3.5.3-bin.tar.gz
MAVEN_FILE_PATH=apache-maven-3.5.3
MAVEN_PATH=/data/service/maven
MAVEN_PROFILE_D=/etc/profile.d/maven.sh

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 下载并解压
wget $MAVEN_URL -O $MAVEN_FILE && tar zxvf $MAVEN_FILE

# 移动
mv $MAVEN_FILE_PATH/* $MAVEN_PATH

# 设置环境变量
cat <<EOF > $MAVEN_PROFILE_D
export PATH=$MAVEN_PATH/bin:\$PATH
EOF

# 更新环境变量
. /etc/profile
