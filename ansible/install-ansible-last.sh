#!/bin/bash
#
# ansible 

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 安装依赖
yum install -y epel-release

# 安装ansible
yum install -y ansible

# 迁移目录
mkdir -p /data/service/ansible
rsync -av /etc/ansible /data/service/
mv /etc/ansible{,_bak}
ln -s /data/service/ansible /etc/ansible