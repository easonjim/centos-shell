#!/bin/bash
#
# 克隆KVM

# 引入外部文件
source ../common/util.sh

# 检查root用户
util::check_root

# clone
virt-clone --connect qemu:///system --original centos6.9-1-clone --name centos6.9-4 --file /data/kvm/image/centos6.9-4.raw
