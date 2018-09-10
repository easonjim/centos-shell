#!/bin/bash
#
# redis 4.0.9

# 解决相对路径问题
cd `dirname $0`

# 定义全局变量
REDIS_URL=http://download.redis.io/releases/redis-4.0.9.tar.gz
REDIS_FILE=redis-4.0.9.tar.gz
REDIS_FILE_PATH=redis-4.0.9
REDIS_PATH=/data/service/redis
REDIS_PROFILE_D=/etc/profile.d/redis.sh
REDIS_INIT_D=/etc/init.d/redis

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 下载并解压
wget $REDIS_URL -O $REDIS_FILE && tar zxvf $REDIS_FILE

# 编译
cd $REDIS_FILE_PATH
make
# 指定目录
make PREFIX=$REDIS_PATH install
cd ..

# 移动
mv $REDIS_FILE_PATH/* $REDIS_PATH

# 设置环境变量
cat <<EOF > $REDIS_PROFILE_D
export PATH=$REDIS_PATH/bin:\$PATH
EOF

# 更新环境变量
. /etc/profile

# 设置开机启动服务
cat > $REDIS_INIT_D <<EOF 
# chkconfig: 2345 10 90  
# redis服务必须在运行级2，3，4，5下被启动或关闭，启动的优先级是90，关闭的优先级是10。
# description: Start and Stop redis
#!/bin/sh
#
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

REDISPORT=6379
EXEC=$REDIS_PATH/bin/redis-server
CLIEXEC=$REDIS_PATH/bin/redis-cli

PIDFILE=/var/run/redis_\${REDISPORT}.pid
CONF="$REDIS_PATH/redis.conf"
AUTH="111111"
# CONF="/etc/redis/\${REDISPORT}.conf"

case "\$1" in
    start)
        if [ -f \$PIDFILE ]
        then
                echo "\$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                \$EXEC \$CONF
        fi
        ;;
    stop)
        if [ ! -f \$PIDFILE ]
        then
                echo "\$PIDFILE does not exist, process is not running"
        else
                PID=\$(cat \$PIDFILE)
                echo "Stopping ..."
                \$CLIEXEC -p \$REDISPORT -a \$AUTH shutdown
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
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
chmod +x $REDIS_INIT_D

# 设置redis配置文件后台模式启动
sed -i 's/daemonize no/daemonize yes/g' $REDIS_PATH/redis.conf

# 开启远程访问
sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' $REDIS_PATH/redis.conf

# 设置开机启动
chkconfig redis on

# 启动
service redis start