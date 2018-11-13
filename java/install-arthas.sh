#!/bin/bash
#
# 阿里JVM诊断工具arthas

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 创建目录
mkdir -p /data/service/arthas

# 下载
cd /data/service/arthas
curl -L https://alibaba.github.io/arthas/install.sh | sh

# 创建环境变量
cat <<EOF >/etc/profile.d/arthas.sh
export ARTHAS_HOME=/data/service/arthas
export PATH=\$ARTHAS_HOME:\$PATH
EOF

# 设置权限
chmod -R 777 /data/service/arthas

# 安装
bash /data/service/arthas/as.sh

# 提示运行：
echo 'arthas install success! run use: as.sh'