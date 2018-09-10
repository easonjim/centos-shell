#!/bin/bash
#
# install kvm for centos 6

# 引入外部文件
source ../common/util.sh

# 检查root用户
util::check_root

#!/bin/bash
#
# install kvm for centos 7

# 引入外部文件
source ../common/util.sh

# 检查root用户
util::check_root

# 网卡名称
INTERFACE=$1
UUID1=`uuidgen`
UUID2=`uuidgen`
IPADDR=$2
NETMASK=$3
GATEWAY=$4
MAC=$5
# 校验变量
if [[ ! -n $1 ]]; then
  echo "请输入INTERFACE,e.g. ./install-kvm_centos_6.sh INTERFACE IPADDR NETMASK GATEWAY MAC"
  exit 1
fi
if [[ ! -n $2 ]]; then
  echo "请输入IPADDR,e.g. ./install-kvm_centos_6.sh INTERFACE IPADDR NETMASK GATEWAY MAC"
  exit 1
fi
if [[ ! -n $3 ]]; then
  echo "请输入NETMASK,e.g. ./install-kvm_centos_6.sh INTERFACE IPADDR NETMASK GATEWAY MAC"
  exit 1
fi
if [[ ! -n $4 ]]; then
  echo "请输入GATEWAY,e.g. ./install-kvm_centos_6.sh INTERFACE IPADDR NETMASK GATEWAY MAC"
  exit 1
fi
if [[ ! -n $5 ]]; then
  echo "请输入MAC,e.g. ./install-kvm_centos_6.sh INTERFACE IPADDR NETMASK GATEWAY MAC"
  exit 1
fi

# 一、准备工作：
# 1、关闭selinux，iptables，重启后生效
# 关闭selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config   #修改配置文件则永久生效，但是必须要重启系统。
# 生效命令
setenforce 0
# 关闭防火墙（这一步可以后续按照业务来添加防火墙，前期先排除防火墙导致的不必要问题）
iptables -F
iptables -X
/etc/init.d/iptables save 
/etc/init.d/iptables stop
# 3、查看系统是否支持KVM虚拟化
# egrep '(vmx|svm)' --color=always /proc/cpuinfo               
# //要有vmx|svm才支持虚拟化
# 4、设置转发，使其KVM可以通过网桥上网
# 开启路由转发功能
sed -i '/net.ipv4.ip_forward/s/0/1/' /etc/sysctl.conf
sysctl -p #生效

# 二、安装KVM必备软件
# 安装KVM所有需要的包
yum -y install kvm python-virtinst libvirt tunctl bridge-utils virt-manager qemu-kvm-tools virt-viewer virt-v2v virt-install
yum -y install libguestfs-tools
systemctl restart libvirtd #重启
ln -s /usr/libexec/qemu-kvm /usr/bin/qemu-kvm

# 三、配置网桥
# 1、关闭NetworkManager服务（桌面版本会有这个服务，服务器版不会安装）
/etc/init.d/NetworkManager stop #停止
chkconfig NetworkManager off #禁止下次自启动
# 2、创建br0网桥（注意粗体部分）
cd /etc/sysconfig/network-scripts/
cp ifcfg-${INTERFACE} ifcfg-br0 
cat <<EOF > ifcfg-${INTERFACE}
DEVICE=${INTERFACE}
TYPE=Ethernet
UUID=${UUID1}
ONBOOT=yes
NM_CONTROLLED=yes
BRIDGE=br0
EOF
cat <<EOF > ifcfg-br0
DEVICE=br0
ONBOOT=yes
HWADDR=${MAC}
NM_CONTROLLED=yes
BOOTPROTO=static
IPADDR=${IPADDR}
NETMASK=${NETMASK}
GATEWAY=${GATEWAY}
TYPE=Bridge
EOF
# 注意：上面配置的网卡信息为静态地址，如果使用DHCP需要对应修改为BOOTPROTO=dhcp
# 3、重启network服务。
/etc/init.d/network restart

# 初始化KVM文件夹
# 创建文件夹
mkdir -p /data/kvm/image
mkdir -p /data/iso