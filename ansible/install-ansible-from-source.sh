#!/bin/bash
#
# install ansible form source code

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 安装epel源，为了安装pip
yum install -y epel-release

# 下载源码
git clone git://github.com/ansible/ansible.git --recursive
cd ./ansible

# 安装pip
yum install -y python-pip
pip install -r ./requirements.txt

# 安装
python setup.py install

# 迁移目录
mkdir -p /data/service/ansible
ln -s /data/service/ansible /etc/ansible
echo "127.0.0.1" > /data/service/ansible/hosts

# 后续更新
# git pull --rebase
# git submodule update --init --recursive
