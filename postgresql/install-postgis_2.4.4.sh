#!/bin/bash
#
# postgis 2.4.4

# 解决相对路径问题
cd `dirname $0`

# 定义全局变量
PARENT_PATH=$(pwd)
POSTGIS_URL=https://download.osgeo.org/postgis/source/postgis-2.4.4.tar.gz
POSTGIS_FILE=postgis-2.4.4.tar.gz
POSTGIS_FILE_PATH=postgis-2.4.4
POSTGIS_PATH=/data/service/postgis
POSTGIS_PROFILE_D=/etc/profile.d/postgis.sh
POSTGRESQL_PATH=/data/service/postgresql
POSTGRESQL_USER=postgres

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 下载并解压
wget $POSTGIS_URL -O $POSTGIS_FILE && tar zxvf $POSTGIS_FILE

# 安装编译依赖
# geos
mkdir -p $POSTGIS_PATH/geos
wget http://download.osgeo.org/geos/geos-3.5.0.tar.bz2 -O geos-3.5.0.tar.bz2
tar -jxvf geos-3.5.0.tar.bz2
cd $PARENT_PATH/geos-3.5.0    
./configure --prefix=$POSTGIS_PATH/geos
make -j 32    
make install
cd $PARENT_PATH/geos-3.5.0/..
# proj4
mkdir -p $POSTGIS_PATH/proj4
wget http://download.osgeo.org/proj/proj-4.9.2.tar.gz -O proj-4.9.2.tar.gz
tar -zxvf proj-4.9.2.tar.gz    
cd $PARENT_PATH/proj-4.9.2    
./configure --prefix=$POSTGIS_PATH/proj4
make -j 32    
make install 
cd $PARENT_PATH/proj-4.9.2/..
# gdal 
mkdir -p $POSTGIS_PATH/gdal
wget http://download.osgeo.org/gdal/2.1.1/gdal-2.1.1.tar.gz -O gdal-2.1.1.tar.gz
tar -zxvf gdal-2.1.1.tar.gz    
cd $PARENT_PATH/gdal-2.1.1
./configure --prefix=$POSTGIS_PATH/gdal --with-pg=$POSTGRESQL_PATH/bin/pg_config    
make -j 32    
make install  
cd $PARENT_PATH/gdal-2.1.1/..
# libxm2...
yum install -y libtool libxml2 libxml2-devel libxslt libxslt-devel json-c json-c-devel cmake gmp gmp-devel mpfr mpfr-devel boost-devel pcre-devel

# 配置上面依赖动态链接库，这一步是为了解决下面编译无法通过时的动态链接库问题
echo "$POSTGRESQL_PATH/lib/" > /etc/ld.so.conf.d/postgresql.conf
echo "$POSTGIS_PATH/proj4/lib/" > /etc/ld.so.conf.d/proj4.conf
echo "$POSTGIS_PATH/gdal/lib/" > /etc/ld.so.conf.d/gdal.conf
echo "$POSTGIS_PATH/geos/lib/" > /etc/ld.so.conf.d/geos.conf
# 生效
ldconfig

# 编译
cd $PARENT_PATH/$POSTGIS_FILE_PATH
# 注意：此变量为PGSQL的目录，不是POSTGIS的目录
./configure --prefix=$POSTGRESQL_PATH --with-gdalconfig=$POSTGIS_PATH/gdal/bin/gdal-config --with-pgconfig=$POSTGRESQL_PATH/bin/pg_config --with-geosconfig=$POSTGIS_PATH/geos/bin/geos-config --with-projdir=$POSTGIS_PATH/proj4
make
make install

# 开启插件
su - $POSTGRESQL_USER -s /bin/sh -c "psql -c 'create extension postgis;'"
su - $POSTGRESQL_USER -s /bin/sh -c "psql -c 'create extension postgis;'"
su - $POSTGRESQL_USER -s /bin/sh -c "psql -c 'create extension postgis_topology;'"
su - $POSTGRESQL_USER -s /bin/sh -c "psql -c 'create extension fuzzystrmatch;'"
su - $POSTGRESQL_USER -s /bin/sh -c "psql -c 'create extension address_standardizer;'"
su - $POSTGRESQL_USER -s /bin/sh -c "psql -c 'create extension address_standardizer_data_us;'"
su - $POSTGRESQL_USER -s /bin/sh -c "psql -c 'create extension postgis_tiger_geocoder;'"

# 测试数据库是否正常
cat <<EOF
# 使用postgres账号登录使用psql客户端连接后，执行以下脚本运算测试
// 测试验证
-- 创建表
create table mytable (
  id serial primary key,
  geom geometry(point, 26910),
  name varchar(128)
);
-- 添加索引
create index mytable_gix
  on mytable
  using gist (geom);
-- 添加一条数据
insert into mytable (geom) values (
  st_geomfromtext('point(0 0)', 26910)
);
-- 测试查询，正常能查出一条数据
select id, name
from mytable
where st_dwithin(
  geom,
  st_geomfromtext('point(0 0)', 26910),
  1000
);
EOF
