#!/bin/bash
# 
# nginx 1.14.0

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 定义全局变量
export PATH=$PATH:/bin:/usr/bin:/usr/local/bin:/usr/sbin
NGINX_ROOT="/data/webapp"
NGINX_PORT=80
NGINX_USER=nginx
NGINX_GROUP=nginx
NGINX_VERSION="nginx-1.14.0"
NGINX_PREFIX="/data/service/nginx"
NGINX_PCRE_VERSION="pcre-8.33"
NGINX_ZLIB_VERSION="zlib-1.2.8"
NGINX_OPENSSL_VERSION="openssl-1.0.2k"
NGINX_COMPILE_COMMAND="--prefix=$NGINX_PREFIX --sbin-path=$NGINX_PREFIX/sbin/nginx --conf-path=$NGINX_PREFIX/etc/nginx.conf --error-log-path=$NGINX_PREFIX/log/nginx.log --pid-path=$NGINX_PREFIX/var/run/nginx.pid --lock-path=$NGINX_PREFIX/var/lock/nginx.lock  --http-log-path=$NGINX_PREFIX/log/access.log --http-client-body-temp-path=$NGINX_PREFIX/client_temp --http-proxy-temp-path=$NGINX_PREFIX/proxy_temp --http-fastcgi-temp-path=$NGINX_PREFIX/fastcgi_temp --http-uwsgi-temp-path=$NGINX_PREFIX/uwsgi_temp --http-scgi-temp-path=$NGINX_PREFIX/scgi_temp --with-pcre=../$NGINX_PCRE_VERSION --with-openssl=../$NGINX_OPENSSL_VERSION --with-zlib=../$NGINX_ZLIB_VERSION --user=$NGINX_USER --group=$NGINX_GROUP --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module  --with-file-aio --with-ipv6 --with-http_realip_module --with-http_gunzip_module --with-http_secure_link_module --with-http_stub_status_module"
NGINX_VHOST_PATH="/data/service/nginx_vhost"
NGINX_BASE_PATH="/data/service/nginx_base"
NGINX_PROFILE_D="/etc/profile.d/nginx.sh"
NGINX_INIT_D="/etc/init.d/nginx"
NGINX_LOG_PATH="/data/weblog/nginx/default"

# 下载
wget http://nginx.org/download/$NGINX_VERSION.tar.gz -O $NGINX_VERSION.tar.gz && tar zxvf $NGINX_VERSION.tar.gz
wget https://ftp.pcre.org/pub/pcre/$NGINX_PCRE_VERSION.tar.gz -O $NGINX_PCRE_VERSION.tar.gz && tar zxvf $NGINX_PCRE_VERSION.tar.gz
wget https://zlib.net/fossils/$NGINX_ZLIB_VERSION.tar.gz -O $NGINX_ZLIB_VERSION.tar.gz && tar zxvf $NGINX_ZLIB_VERSION.tar.gz
wget https://www.openssl.org/source/$NGINX_OPENSSL_VERSION.tar.gz -O $NGINX_OPENSSL_VERSION.tar.gz && tar zxvf $NGINX_OPENSSL_VERSION.tar.gz

# 安装编译依赖
yum install -y  zlib zlib-devel openssl openssl-devel pcre pcre-devel gcc gcc-c++ make

# 添加用户
groupadd $NGINX_GROUP
useradd -g $NGINX_GROUP -s /sbin/nologin $NGINX_USER

# 编译安装
tar zxvf $NGINX_ZLIB_VERSION.tar.gz 
cd $NGINX_ZLIB_VERSION
./configure && make && make install
cd ../
tar zxvf $NGINX_PCRE_VERSION.tar.gz 
cd $NGINX_PCRE_VERSION
./configure && make && make install
cd ../
tar zxvf $NGINX_OPENSSL_VERSION.tar.gz
tar zxvf $NGINX_VERSION.tar.gz
cd $NGINX_VERSION
./configure $NGINX_COMPILE_COMMAND
make -j8 && make install
mkdir -p $NGINX_PREFIX/var/lock/

# 修改配置文件
cat <<EOF > $NGINX_PREFIX/etc/nginx.conf 

user  nginx;
worker_processes  auto;

error_log  $NGINX_LOG_PATH/error.log;
#error_log  $NGINX_LOG_PATH/error.log  notice;
#error_log  $NGINX_LOG_PATH/error.log  info;

pid        var/run/nginx.pid;


events {
    use epoll;
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  $NGINX_LOG_PATH/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       $NGINX_PORT;
        server_name  localhost;

        #charset koi8-r;

        #access_log  $NGINX_LOG_PATH/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
    include $NGINX_BASE_PATH/*.conf;
    include $NGINX_VHOST_PATH/*.conf;
}
EOF

# 配置环境变量
cat <<EOF > $NGINX_PROFILE_D
export PATH=$NGINX_PREFIX/sbin:\$PATH
EOF

# 更新环境变量
. /etc/profile

# 设置开机启动服务
cat > $NGINX_INIT_D <<EOF
#!/bin/sh

# chkconfig:   - 85 15
# description:  Nginx is an HTTP(S) server, HTTP(S) reverse proxy and IMAP/POP3 proxy server

. /etc/rc.d/init.d/functions
if [ -f /etc/sysconfig/nginx ]; then
    . /etc/sysconfig/nginx
fi
prog=nginx
nginx=\${NGINX-$NGINX_PREFIX/sbin/nginx}
conffile=\${CONFFILE-$NGINX_PREFIX/etc/nginx.conf}
lockfile=\${LOCKFILE-$NGINX_PREFIX/var/lock/nginx.lock}
pidfile=\${PIDFILE-$NGINX_PREFIX/var/run/nginx.pid}
SLEEPMSEC=100000
RETVAL=0
start() {
    echo -n \$"Starting \$prog: "
    daemon --pidfile=\${pidfile} \${nginx} -c \${conffile}
    RETVAL=\$?
    echo
    [ \$RETVAL = 0 ] && touch \${lockfile}
    return \$RETVAL
}
stop() {
    echo -n \$"Stopping \$prog: "
    killproc -p \${pidfile} \${prog}
    RETVAL=\$?
    echo
    [ \$RETVAL = 0 ] && rm -f \${lockfile} \${pidfile}
}
reload() {
    echo -n \$"Reloading \$prog: "
    killproc -p \${pidfile} \${prog} -HUP
    RETVAL=\$?
    echo
}
upgrade() {
    oldbinpidfile=\${pidfile}.oldbin
    configtest -q || return 6
    echo -n \$"Staring new master \$prog: "
    killproc -p \${pidfile} \${prog} -USR2
    RETVAL=\$?
    echo
    /bin/usleep \$SLEEPMSEC
    if [ -f \${oldbinpidfile} -a -f \${pidfile} ]; then
        echo -n \$"Graceful shutdown of old \$prog: "
        killproc -p \${oldbinpidfile} \${prog} -QUIT
        RETVAL=\$?
        echo
    else
        echo \$"Upgrade failed!"
        return 1
    fi
}
configtest() {
    if [ "\$#" -ne 0 ] ; then
        case "\$1" in
            -q)
                FLAG=\$1
                ;;
            *)
                ;;
        esac
        shift
    fi
    \${nginx} -t -c \${conffile} \$FLAG
    RETVAL=\$?
    return \$RETVAL
}
rh_status() {
    status -p \${pidfile} \${nginx}
}
# See how we were called.
case "\$1" in
    start)
        rh_status >/dev/null 2>&1 && exit 0
        start
        ;;
    stop)
        stop
        ;;
    status)
        rh_status
        RETVAL=\$?
        ;;
    restart)
        configtest -q || exit \$RETVAL
        stop
        start
        ;;
    upgrade)
        upgrade
        ;;
    condrestart|try-restart)
        if rh_status >/dev/null 2>&1; then
            stop
            start
        fi
        ;;
    force-reload|reload)
        reload
        ;;
    configtest)
        configtest
        ;;
    *)
        echo \$"Usage: \$prog {start|stop|restart|condrestart|try-restart|force-reload|upgrade|reload|status|help|configtest}"
        RETVAL=2
esac
exit \$RETVAL
EOF
chmod 777 $NGINX_INIT_D

# 设置开机启动
chkconfig nginx on

# 启动
service nginx start 

# 设置用户隶属于www-data用户组
usermod -aG www-data nginx