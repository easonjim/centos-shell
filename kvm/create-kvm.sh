#!/bin/bash
#
# 创建KVM

# 引入外部文件
source ../common/util.sh

# 检查root用户
util::check_root

# 创建虚拟机镜像文件
qemu-img create -f raw /data/kvm/images/centos6.raw 100G
# 创建KVM虚拟机
virt-install --name centos6 --ram 1024 --vcpus=1 --disk path=/data/kvm/image/centos6.raw --network bridge=br0 --cdrom=/data/iso/CentOS-6.9-x86_64-bin-DVD1.iso --accelerate --vnclisten=0.0.0.0 --vncport=5900 --vnc