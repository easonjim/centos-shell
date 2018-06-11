#!/bin/bash
#
# tomcat 8.5.31

# 定义全局变量
TOMCAT_URL=http://mirror.bit.edu.cn/apache/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz
TOMCAT_FILE=apache-tomcat-8.5.31.tar.gz
TOMCAT_FILE_PATH=apache-tomcat-8.5.31
TOMCAT_PATH=/data/service/tomcat/
TOMCAT_PROFILE_D=/etc/profile.d/tomcat.sh
TOMCAT_INIT_D=/etc/init.d/tomcat8

# 检查是否为root用户，脚本必须在root权限下运行
source common/check-root.sh

# 下载并解压
wget $TOMCAT_URL -O $TOMCAT_FILE && tar zxvf $TOMCAT_FILE

# 移动
mv $TOMCAT_FILE_PATH/* $TOMCAT_PATH

# 设置开启启动服务
cp $TOMCAT_PATH/bin/catalina.sh $TOMCAT_INIT_D
mkdir -p /etc/logs/
mkdir -p /etc/bin/
cp $TOMCAT_PATH/bin/setclasspath.sh /etc/bin/setclasspath.sh
chkconfig tomcat8 on

# 启动
service tomcat8 start