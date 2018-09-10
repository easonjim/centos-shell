#!/bin/bash
#
# php 7.1.21

# 解决相对路径问题
cd `dirname $0`

# 定义全局变量
PHP_URL=http://cn2.php.net/distributions/php-7.1.21.tar.gz
PHP_FILE=php-7.1.21.tar.gz
PHP_FILE_PATH=php-7.1.21
PHP_PATH=/data/service/php
PHP_ETC_PATH=/data/service/php/etc
PHP_PROFILE_D=/etc/profile.d/php.sh

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 下载php
yum install -y wget
wget ${PHP_URL} -O ${PHP_FILE}
# 解压 
tar -zxvf ${PHP_FILE}
cd ${PHP_FILE_PATH}
# 编译：
# 安装epel
yum install -y epel-release
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
# 安装编译依赖
yum install -y libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel \
 libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel \
 gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel gcc 
# 创建目录
mkdir -p ${PHP_ETC_PATH}
./configure \
--prefix=${PHP_PATH} \
--with-config-file-path=${PHP_ETC_PATH} \
--enable-fpm \
--with-fpm-user=nginx \
--with-fpm-group=nginx \
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared \
--enable-soap \
--with-libxml-dir \
--with-xmlrpc \
--with-openssl \
--with-mcrypt \
--with-mhash \
--with-pcre-regex \
--with-sqlite3 \
--with-zlib \
--enable-bcmath \
--with-iconv \
--with-bz2 \
--enable-calendar \
--with-curl \
--with-cdb \
--enable-dom \
--enable-exif \
--enable-fileinfo \
--enable-filter \
--with-pcre-dir \
--enable-ftp \
--with-gd \
--with-openssl-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib-dir \
--with-freetype-dir \
--enable-gd-native-ttf \
--enable-gd-jis-conv \
--with-gettext \
--with-gmp \
--with-mhash \
--enable-json \
--enable-mbstring \
--enable-mbregex \
--enable-mbregex-backtrack \
--with-libmbfl \
--with-onig \
--enable-pdo \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-zlib-dir \
--with-pdo-sqlite \
--with-readline \
--enable-session \
--enable-shmop \
--enable-simplexml \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-wddx \
--with-libxml-dir \
--with-xsl \
--enable-zip \
--enable-mysqlnd-compression-support \
--with-pear \
--enable-opcache
make && make install
# 增加环境变量
cat <<EOF > ${PHP_PROFILE_D}
export PATH=${PHP_PATH}/bin:\$PATH
EOF
# 生效环境变量
. /etc/profile
# 配置php-fpm
cp php.ini-production ${PHP_ETC_PATH}/php.ini
cp ${PHP_ETC_PATH}/php-fpm.conf.default ${PHP_ETC_PATH}/php-fpm.conf
cp ${PHP_ETC_PATH}/php-fpm.d/www.conf.default ${PHP_ETC_PATH}/php-fpm.d/www.conf
# 配置php-fpm服务
# 注意：这个文件是根据上面C++编译配置动态生成的文件，里面写了上面配置的路径
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
# 启动权限
chmod +x /etc/init.d/php-fpm
# 启动：
# 增加开机启动
chkconfig --add php-fpm
service php-fpm start
# 注意：php-fpm需要nginx用户，当然你可以自行增加，也可以直接安装nginx。