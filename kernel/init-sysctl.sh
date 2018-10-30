#!/bin/bash
#
# 优化内核参数

# 引入外部文件
source ../common/util.sh

# 检查root
util::check_root

modprobe br_netfilter
# 为了开机加载上面这个模块
cat > /etc/rc.sysinit << EOF
#!/bin/bash
for file in /etc/sysconfig/modules/*.modules ; do
[ -x $file ] && $file
done
EOF
cat > /etc/sysconfig/modules/br_netfilter.modules << EOF
modprobe br_netfilter
EOF
chmod 755 /etc/sysconfig/modules/br_netfilter.modules
lsmod |grep br_netfilter

cat > /etc/sysctl.conf << EOF
net.ipv4.ip_forward = 1        
# 开启路由功能
net.ipv4.conf.all.rp_filter = 1
# 加强入站过滤和出站过滤（如果配置了多张网卡且每张网卡在不同的网段时此项应该设置为0）
net.ipv4.conf.default.rp_filter = 1
# 开启反向路径过滤（如果配置了多张网卡且每张网卡在不同的网段时此项应该设置为0）
net.ipv4.conf.default.accept_source_route = 0
# 处理无源路由的包
kernel.sysrq = 0
# 控制系统调试内核的功能要求
kernel.core_uses_pid = 1
# 用于调试多线程应用程序
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
kernel.msgmnb = 65536
# 所有在消息队列中的消息总和的最大值
kernel.msgmax = 65536
# 指定内核中消息队列中消息的最大值
kernel.shmmax = 68719476736
# 对于定义单个共享内存段的最大值，64位linux系统：可取的最大值为物理内存值-1byte，建议值为多于物理内存的一半，一般取值大于SGA_MAX_SIZE即可，可以取物理内存-1byte。例如，如果为64GB物理内存，可取64*1024*1024*1024-1=68719476735
kernel.shmall = 4294967296
# linux共享内存页大小为4KB,共享内存段的大小都是共享内存页大小的整数倍。一个共享内存段的最大大小是 16G，那么需要共享内存页数是16GB/4KB=16777216KB /4KB=4194304（页），也就是64Bit系统下16GB物理内存，设置kernel.shmall = 4194304才符合要求(几乎是原来设置2097152的两倍)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
# 内存资源使用相关设定
net.core.wmem_default = 8388608 
net.core.rmem_default = 8388608 
net.core.rmem_max = 16777216 
net.core.wmem_max = 16777216 
net.ipv4.tcp_rmem = 4096 65536 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216     
net.ipv4.tcp_mem = 8388608 8388608 8388608
# 应对DDOS攻击,TCP连接建立设置
net.ipv4.tcp_syncookies = 1
# 防止syn flood攻击
net.ipv4.tcp_synack_retries = 1 
net.ipv4.tcp_syn_retries = 1 
net.ipv4.tcp_max_syn_backlog = 262144
# SYN队列的长度，默认为1024，加大队列长度为262144，可以容纳更多等待连接的网络连接数
# 应对timewait过高,TCP连接断开设置
net.ipv4.tcp_max_tw_buckets = 10000 
# 默认是180000。表示系统同时保持TIME_WAIT的最大数量，如果超过这个数字，TIME_WAIT将立刻被清除并打印警告信息
net.ipv4.tcp_tw_recycle = 1 
# 表示开启TCP连接中TIME-WAIT sockets的快速收回功能，默认为 0 ，表示关闭。
net.ipv4.tcp_tw_reuse = 1 
# 表示开启重用。允许将TIME-WAIT sockets重新用于新的 TCP 连接，默认为 0 表示关闭
net.ipv4.tcp_timestamps = 0 
# 时间戳可以避免序列号的卷绕
net.ipv4.tcp_fin_timeout = 5
# 表示如果套接字由本端要求关闭，这个参数决定了它保持在FIN-WAIT-2状态的时间。对端可以出错并永远不关闭连接，甚至意外当机。缺省值是60  秒。2.2 内核的通常值是180 秒，3你可以按这个设置，但要记住的是，即使你的机器是一个轻载的WEB  服务器，也有因为大量的死套接字而内存溢出的风险，FIN- WAIT-2 的危险性比FIN-WAIT-1 要小，因为它最多只能吃掉1.5K  内存，但是它们的生存期长些
net.ipv4.ip_local_port_range = 4000 65000
# 表示用于向外连接的端口范围
# TCP keepalived 连接保鲜设置
net.ipv4.tcp_keepalive_time = 1200
# 表示当keepalive起用的时候，TCP发送keepalive消息的频度。缺省是2小时，改为20分钟
net.ipv4.tcp_keepalive_intvl = 15
# 当探测没有确认时，重新发送探测的频度。缺省是75
net.ipv4.tcp_keepalive_probes = 5
# 在认定连接失效之前，发送多少个TCP的keepalive探测包。缺省值是9。这个值乘以tcp_keepalive_intvl之后决定了，一个连接发送了keepalive之后可以有多少时间没有回应
# 其他TCP相关调节
net.core.somaxconn = 65535
# isten(函数)的默认参数,挂起请求的最大数量限制。web 应用中listen 函数的backlog 默认会给我们内核参数的net.core.somaxconn 限制到128，而nginx 定义的NGX_LISTEN_BACKLOG 默认为511，所以有必要调整这个值
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
EOF
sysctl -p 
# 生产环境各不相同，内核优化需慎重，请一个个参数逐一测试