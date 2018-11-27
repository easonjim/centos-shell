#!/bin/bash
#
# docker install jenkins

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 下载镜像
# 最新版
docker pull jenkinsci/blueocean
# 指定版
# docker pull jenkinsci/blueocean:1.3.6

# 创建目录
mkdir -p /data/service/jenkins/jenkins_home

# 运行
docker run \
  -u root \
  --rm \
  -d \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /data/service/jenkins/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkinsci/blueocean


