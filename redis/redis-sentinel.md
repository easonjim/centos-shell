# Redis Sentinel 哨兵模式集群搭建
哨兵不能直接使用客户端操作，只能查看同步信息，基于Java的应用客户端选择兼容哨兵模式的，并执行组名（下面配置的为mymaster）  
注意：哨兵和Redis同在一台服务器时，可以使用127.0.0.1这样的IP，当服务器>=2时，就只能使用内网或者外网IP，不然会造成Redis无法连接主库，以及导致哨兵找不到主库。
## 启动顺序
Redis(Master->Salve)->Sentinel
## 哨兵数量
2n+1（n>=1）  
哨兵建议装在从机，这里演示的哨兵数量为3：
- sentinel-26301.conf
- sentinel-26302.conf
- sentinel-26303.conf
## Redis主从数量
1主n从（n>=1）  
这里演示的Redis主从数量为3:  
- redis-6301.conf
- redis-6302.conf
- redis-6303.conf
## Redis主从集群搭建
### 停止原有Redis服务
```shell
chkconfig redis off
service redis stop
```
### 配置文件
```shell
# 创建文件夹
mkdir -p /data/service/redis_base/redis_group
# 复制配置文件
cp /data/service/redis/redis.conf /data/service/redis_base/redis_group/redis-6301.conf
cp /data/service/redis/redis.conf /data/service/redis_base/redis_group/redis-6302.conf
cp /data/service/redis/redis.conf /data/service/redis_base/redis_group/redis-6303.conf
# 修改配置文件
# 修改redis-6301.conf配置文件
vim /data/service/redis_base/redis_group/redis-6301.conf
# 将参数的值改为以下
daemonize yes
pidfile /var/run/redis6301.pid
port 6301
logfile "6301.log"
dbfilename dump6301.rdb
bind 内网IP
# 修改redis-6302.conf
vim /data/service/redis_base/redis_group/redis-6302.conf
daemonize yes
pidfile /var/run/redis6302.pid
port 6302
logfile "6302.log"
dbfilename dump6302.rdb
bind 内网IP
# 修改redis-6303.conf
vim /data/service/redis_base/redis_group/redis-6303.conf
daemonize yes
pidfile /var/run/redis6303.pid
port 6303
logfile "6303.log"
dbfilename dump6303.rdb
bind 内网IP
```
### 配置主从
```shell
# 启动Redis
redis-server /data/service/redis_base/redis_group/redis-6301.conf
redis-server /data/service/redis_base/redis_group/redis-6302.conf
redis-server /data/service/redis_base/redis_group/redis-6303.conf
# 进入客户端，分三个终端窗口
redis-cli -p 6301
redis-cli -p 6302
redis-cli -p 6303
# 在6302执行从库操作
SLAVEOF 内网IP 6301
# 在6303执行从库操作
SLAVEOF 内网IP 6301
```
### 配置哨兵模式
```shell
# 配置配置文件
# 除了端口不一样，其余基本相同
# 第一个
cat > /data/service/redis_base/redis_group/sentinel-26301.conf <<EOF
# 使用宿主进程启动
daemonize yes
# 去除保护模式
protected-mode no
# 启动目录
dir "/data/service/redis/bin"
# 日期文件路径
logfile "/data/service/redis_base/redis_group/sentinel-26301.log"
# PID
pidfile "/var/run/sentinel26301.pid"
# 监听Redis主机地址及端口
port 26301
# Redis主节点，以及最后面代表的协商数量，当只有2个人同时选择才通过
sentinel monitor mymaster 内网IP 6301 2
# 优化同步参数
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF
# 第二个
cat > /data/service/redis_base/redis_group/sentinel-26302.conf <<EOF
# 使用宿主进程启动
daemonize yes
# 去除保护模式
protected-mode no
# 启动目录
dir "/data/service/redis/bin"
# 日期文件路径
logfile "/data/service/redis_base/redis_group/sentinel-26302.log"
# PID
pidfile "/var/run/sentinel26302.pid"
# 监听Redis主机地址及端口
port 26302
# Redis主节点，以及最后面代表的协商数量，当只有2个人同时选择才通过
sentinel monitor mymaster 内网IP 6301 2
# 优化同步参数
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF
# 第三个
cat > /data/service/redis_base/redis_group/sentinel-26303.conf <<EOF
# 使用宿主进程启动
daemonize yes
# 去除保护模式
protected-mode no
# 启动目录
dir "/data/service/redis/bin"
# 日期文件路径
logfile "/data/service/redis_base/redis_group/sentinel-26303.log"
# PID
pidfile "/var/run/sentinel26303.pid"
# 监听Redis主机地址及端口
port 26303
# Redis主节点，以及最后面代表的协商数量，当只有2个人同时选择才通过
sentinel monitor mymaster 内网IP 6301 2
# 优化同步参数
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel parallel-syncs mymaster 1
EOF
# 启动哨兵
redis-sentinel /data/service/redis_base/redis_group/sentinel-26301.conf
redis-sentinel /data/service/redis_base/redis_group/sentinel-26302.conf
redis-sentinel /data/service/redis_base/redis_group/sentinel-26303.conf
```
### 配置开机启动服务
以下脚本根据环境修改配置即可，由于Redis和Sentinel放在同一台，所以集成在一起
```shell
cat > /etc/init.d/redis-sentinel <<EOF 
# chkconfig: 2345 10 90  
# redis服务必须在运行级2，3，4，5下被启动或关闭，启动的优先级是90，关闭的优先级是10。
# description: Start and Stop redis-sentinel
#!/bin/sh
#
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

CLIEXEC=/data/service/redis/bin/redis-cli
EXEC_PATH=/data/service/redis/bin

AUTH="111111"

case "\$1" in
    start)
        # 启动Redis主从模式
        if [ -f /var/run/redis6301.pid ]
        then
                echo "/var/run/redis6301.pid exists, process is already running or crashed"
        else
                echo "Starting Redis 6301 server..."
                \$EXEC_PATH/redis-server /data/service/redis_base/redis_group/redis-6301.conf
        fi
        if [ -f /var/run/redis6302.pid ]
        then
                echo "/var/run/redis6302.pid exists, process is already running or crashed"
        else
                echo "Starting Redis 6302 server..."
                \$EXEC_PATH/redis-server /data/service/redis_base/redis_group/redis-6302.conf
        fi
        if [ -f /var/run/redis6303.pid ]
        then
                echo "/var/run/redis6303.pid exists, process is already running or crashed"
        else
                echo "Starting Redis 6303 server..."
                \$EXEC_PATH/redis-server /data/service/redis_base/redis_group/redis-6303.conf
        fi
        # 启动Sentinel哨兵模式
        if [ -f /var/run/sentinel26301.pid ]
        then
                echo "/var/run/sentinel26301.pid exists, process is already running or crashed"
        else
                echo "Starting Redis Sentinel 26301 server..."
                \$EXEC_PATH/redis-sentinel /data/service/redis_base/redis_group/sentinel-26301.conf
        fi
        if [ -f /var/run/sentinel26302.pid ]
        then
                echo "/var/run/sentinel26302.pid exists, process is already running or crashed"
        else
                echo "Starting Redis Sentinel 26302 server..."
                \$EXEC_PATH/redis-sentinel /data/service/redis_base/redis_group/sentinel-26302.conf
        fi
        if [ -f /var/run/sentinel26303.pid ]
        then
                echo "/var/run/sentinel26303.pid exists, process is already running or crashed"
        else
                echo "Starting Redis Sentinel 26303 server..."
                \$EXEC_PATH/redis-sentinel /data/service/redis_base/redis_group/sentinel-26303.conf
        fi
        ;;
    stop)
        # 停止Sentinel哨兵
        if [ ! -f /var/run/sentinel26301.pid ]
        then
                echo "/var/run/sentinel26301.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/sentinel26301.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 26301 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis Sentinel 26301 to shutdown ..."
                    sleep 1
                done
                echo "Redis Sentinel 26301 stopped"
        fi
        if [ ! -f /var/run/sentinel26302.pid ]
        then
                echo "/var/run/sentinel26302.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/sentinel26302.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 26302 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis Sentinel 26302 to shutdown ..."
                    sleep 1
                done
                echo "Redis Sentinel 26302 stopped"
        fi
        if [ ! -f /var/run/sentinel26303.pid ]
        then
                echo "/var/run/sentinel26303.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/sentinel26303.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 26303 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis Sentinel 26303 to shutdown ..."
                    sleep 1
                done
                echo "Redis Sentinel 26303 stopped"
        fi
        # 停止Redis主从
        if [ ! -f /var/run/redis6301.pid ]
        then
                echo "/var/run/redis6301.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/redis6301.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 6301 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis 6301 stopped"
        fi
        if [ ! -f /var/run/redis6302.pid ]
        then
                echo "/var/run/redis6302.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/redis6302.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 6302 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis 6302 stopped"
        fi
        if [ ! -f /var/run/redis6303.pid ]
        then
                echo "/var/run/redis6303.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/redis6303.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 6303 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis 6303 stopped"
        fi
        ;;
    restart|force-reload)
        \${0} stop
        \${0} start
        ;;
    *)
        echo "Please use start or stop as first argument"
        ;;
esac
EOF
# 设置权限
chmod +x /etc/init.d/redis-sentinel
# 添加到开机启动
chkconfig redis-sentinel on
```
### 其它服务器设置Redis从节点
只需要修改端口，以及主节点的IP即可，原理就是往上叠加从节点
```shell
# 创建文件夹
mkdir -p /data/service/redis_base/redis_group
# 复制配置文件
cp /data/service/redis/redis.conf /data/service/redis_base/redis_group/redis-6304.conf
cp /data/service/redis/redis.conf /data/service/redis_base/redis_group/redis-6305.conf
cp /data/service/redis/redis.conf /data/service/redis_base/redis_group/redis-6306.conf
# 修改配置文件
# 修改redis-6304.conf配置文件
vim redis-6304.conf
# 将参数的值改为以下
daemonize yes
pidfile /var/run/redis6304.pid
port 6304
logfile "6304.log"
dbfilename dump6304.rdb
bind 内网IP
# 修改redis-6305.conf
vim redis-6305.conf
daemonize yes
pidfile /var/run/redis6305.pid
port 6305
logfile "6305.log"
dbfilename dump6305.rdb
bind 内网IP
# 修改redis-6306.conf
vim redis-6306.conf
daemonize yes
pidfile /var/run/redis6306.pid
port 6306
logfile "6306.log"
dbfilename dump6306.rdb
内网IP
# 启动Redis
redis-server /data/service/redis_base/redis_group/redis-6304.conf
redis-server /data/service/redis_base/redis_group/redis-6305.conf
redis-server /data/service/redis_base/redis_group/redis-6306.conf
# 进入客户端，分三个终端窗口
redis-cli -p 6304
redis-cli -p 6305
redis-cli -p 6306
# 在6304执行从库操作
SLAVEOF 主节点内网IP 6301
# 在6305执行从库操作
SLAVEOF 主节点内网IP 6301
# 在6306执行从库操作
SLAVEOF 主节点内网IP 6301
# 配置开机启动服务
cat > /etc/init.d/redis-sentinel <<EOF 
# chkconfig: 2345 10 90  
# redis服务必须在运行级2，3，4，5下被启动或关闭，启动的优先级是90，关闭的优先级是10。
# description: Start and Stop redis-sentinel
#!/bin/sh
#
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

CLIEXEC=/data/service/redis/bin/redis-cli
EXEC_PATH=/data/service/redis/bin

AUTH="111111"

case "\$1" in
    start)
        # 启动Redis主从模式
        if [ -f /var/run/redis6304.pid ]
        then
                echo "/var/run/redis6304.pid exists, process is already running or crashed"
        else
                echo "Starting Redis 6304 server..."
                \$EXEC_PATH/redis-server /data/service/redis_base/redis_group/redis-6304.conf
        fi
        if [ -f /var/run/redis6305.pid ]
        then
                echo "/var/run/redis6305.pid exists, process is already running or crashed"
        else
                echo "Starting Redis 6305 server..."
                \$EXEC_PATH/redis-server /data/service/redis_base/redis_group/redis-6305.conf
        fi
        if [ -f /var/run/redis6306.pid ]
        then
                echo "/var/run/redis6306.pid exists, process is already running or crashed"
        else
                echo "Starting Redis 6306 server..."
                \$EXEC_PATH/redis-server /data/service/redis_base/redis_group/redis-6306.conf
        fi
        ;;
    stop)
        # 停止Redis主从
        if [ ! -f /var/run/redis6304.pid ]
        then
                echo "/var/run/redis6304.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/redis6304.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 6304 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis 6304 stopped"
        fi
        if [ ! -f /var/run/redis6305.pid ]
        then
                echo "/var/run/redis6305.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/redis6305.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 6305 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis 6305 stopped"
        fi
        if [ ! -f /var/run/redis6306.pid ]
        then
                echo "/var/run/redis6306.pid does not exist, process is not running"
        else
                PID=\$(cat /var/run/redis6306.pid)
                echo "Stopping ..."
                \$CLIEXEC -p 6306 -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis 6306 stopped"
        fi
        ;;
    restart|force-reload)
        \${0} stop
        \${0} start
        ;;
    *)
        echo "Please use start or stop as first argument"
        ;;
esac
EOF
# 设置开机脚本权限
chmod +x /etc/init.d/redis-sentinel
# 添加到开机启动
chkconfig redis-sentinel on
```