#!/bin/bash
# 
# nexus 3.14.0

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 下载
# https://www.sonatype.com/download-oss-sonatype
wget https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.14.0-04-unix.tar.gz -O nexus-3.14.0-04-unix.tar.gz 

# 解压
tar -zxvf nexus-3.14.0-04-unix.tar.gz

# 转移
mkdir -p /data/service/nexus
mv nexus* /data/service/nexus/  
mv sonatype-work /data/service/nexus/

# 创建用户并授权(需要提前创建www-data用户和用户组，因为/data目录为www-data所有)
useradd nexus
usermod -a -G www-data nexus
chmod -R 775 /data/service/nexus
chown -R www-data:www-data /data/service/nexus

# 修改启动配置
# 启动用户
echo "run_as_user=\"nexus\"" > /data/service/nexus/nexus-3.14.0-04/bin/nexus.rc
# 仓库目录(可选)
# sed -i 's/-Dkaraf.data=..\/sonatype-work\/nexus3/-Dkaraf.data=\/data\/nexus-data/g'  /data/service/nexus/nexus-3.14.0-04/bin/nexus.vmoptions
# Java启动环境变量(必须要具体地址，不能用变量)
sed -i 's/# INSTALL4J_JAVA_HOME_OVERRIDE=/INSTALL4J_JAVA_HOME_OVERRIDE=\/data\/service\/java/g' /data/service/nexus/nexus-3.14.0-04/bin/nexus

# 创建开机启动项
ls -n /data/service/nexus/nexus-3.14.0-04/bin/nexus /etc/init.d/nexus
chkconfig --add nexus
chkconfig nexus on

# 启动
service nexus start
# 调试输出
# service nexus run