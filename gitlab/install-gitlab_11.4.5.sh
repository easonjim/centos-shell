#!/bin/bash
# 
# gitlab 11.4.5

# 解决相对路径问题
cd `dirname $0`

# 检查是否为root用户，脚本必须在root权限下运行
source ../common/util.sh
util::check_root

# 安装依赖
yum install -y curl policycoreutils-python

yum install -y postfix
systemctl enable postfix
systemctl start postfix
# fix postfix in centos bug
sed -i 's/inet_interfaces = localhost/inet_interfaces = all' /etc/postfix/main.cf
service postfix restart

# 下载安装
wget https://mirror.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-11.4.5-ce.0.el7.x86_64.rpm -O gitlab-ce-11.4.5-ce.0.el7.x86_64.rpm
rpm -i gitlab-ce-11.4.5-ce.0.el7.x86_64.rpm

# 修改配置
# 域名(可选)
# sed -i 's/external_url \'http://gitlab.example.com\'/external_url \'http://gitlab.jsoft.com\'/g' /etc/gitlab/gitlab.rb
# 迁移目录
mv /var/opt/gitlab/git-data{,_bak}
mkdir -p /data/service/gitlab/git-data
chmod 775 /data
chmod 775 /data/service
chmod -R 775 /data/service/gitlab
rsync -av /var/opt/gitlab/git-data/repositories /data/service/gitlab/git-data/
ls -n /data/service/gitlab/git-data /var/opt/gitlab/git-data

# 启动
gitlab-ctl reconfigure
gitlab-ctl restart