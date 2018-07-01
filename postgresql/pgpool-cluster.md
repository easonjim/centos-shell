# 基于pgpool2的集群搭建
pg的流复制+pgpool的负载均衡模式
```shell
cat > /etc/init.d/pgpool <<EOF 
# chkconfig: 2345 10 90  
# 服务必须在运行级2，3，4，5下被启动或关闭，启动的优先级是90，关闭的优先级是10。
# description: Start and Stop pgpool
#!/bin/sh
#
# Simple init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

EXEC=/data/service/pgpool/bin/pgpool

PIDFILE=/var/run/pgpool/pgpool.pid

PGUSER=postgres

case "\$1" in
    start)
        if [ -f \$PIDFILE ]
        then
                echo "\$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting pgpool server..."
                su - \$PGUSER -c "\$EXEC -n > /tmp/pgpool.log 2>&1 &"
        fi
        ;;
    stop)
        if [ ! -f \$PIDFILE ]
        then
                echo "\$PIDFILE does not exist, process is not running"
        else
                PID=\$(cat \$PIDFILE)
                echo "Stopping ..."
                su - \$PGUSER -c "\$EXEC -m fast stop"
                while [ -x /proc/\${PID} ]
                do
                    echo "Waiting for pgpool to shutdown ..."
                    sleep 1
                done
                echo "pgpool stopped"
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
```