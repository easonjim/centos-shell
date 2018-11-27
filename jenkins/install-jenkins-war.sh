#!/bin/bash
#
# war install jenkins

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 下载war包
# 在此地址下载war包http://mirrors.jenkins.io/war-stable/
wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war -O jenkins.war

# 创建用户
# 先清理旧用户
userdel jenkins
groupdel jenkins
useradd jenkins
usermod -aG www-data jenkins

# 创建文件夹，移动目录
mkdir -p /data/service/jenkins
mkdir -p /data/service/jenkins/.jenkins
mv jenkins.war /data/service/jenkins/
# 修改目录权限
chown -R www-data:www-data /data/service/jenkins
chown -R jenkins:jenkins /data/service/jenkins/.jenkins

# 安装start-stop-daemon
wget http://ftp.de.debian.org/debian/pool/main/d/dpkg/dpkg_1.16.18.tar.xz -O dpkg_1.16.18.tar.xz
tar -xf dpkg_1.16.18.tar.xz && cd dpkg-1.16.18
yum install ncurses-devel -y
./configure && make && make install

# 创建开机启动服务
cat <<"EOF" > /etc/init.d/jenkins
#!/bin/sh

# chkconfig:   - 85 15
# description:  Jenkins CI Server

DESC="Jenkins CI Server"
NAME=jenkins
PIDFILE=/var/run/$NAME.pid
RUN_AS=jenkins
COMMAND="/usr/bin/java -- -DJENKINS_HOME=/data/service/jenkins/.jenkins -jar /data/service/jenkins/jenkins.war"
START_STOP_DAEMON=/usr/local/sbin/start-stop-daemon
 
d_start() {
    $START_STOP_DAEMON --start --quiet --background -C --make-pidfile --pidfile $PIDFILE --chuid $RUN_AS --exec $COMMAND > /var/log/jenkins.log 2>&1
}
 
d_stop() {
    $START_STOP_DAEMON --stop --quiet --pidfile $PIDFILE
    if [ -e $PIDFILE ]
        then rm $PIDFILE
    fi
}
 
case $1 in
    start)
    echo -n "Starting $DESC: $NAME"
    d_start
    echo "."
    ;;
    stop)
    echo -n "Stopping $DESC: $NAME"
    d_stop
    echo "."
    ;;
    restart)
    echo -n "Restarting $DESC: $NAME"
    d_stop
    sleep 1
    d_start
    echo "."
    ;;
    *)
    echo "usage: $NAME {start|stop|restart}"
    exit 1
    ;;
esac
 
exit 0
EOF
chmod +x /etc/init.d/jenkins
chkconfig --add jenkins