# centos-shell
CentOS常用Shell  
注意：如无特殊标识，默认运行环境为CentOS 7+，默认下载到/root/centos-shell（为便于配置，请勿更改此目录）
## 获取方法
```shell
curl https://raw.githubusercontent.com/easonjim/centos-shell/master/init.sh | bash
```
## 使用前需要设置脚本可执行权限（非必须）
```shell
chmod +x xxx.sh
```
## 快速使用脚本（使用之前必须新建好文件夹）
```shell
bash /root/centos-shell/directory/init-directory.sh
bash /root/centos-shell/customer-install-shell/install-centos7.sh
bash /root/centos-shell/customer-install-shell/install-runtime-centos7.sh
```
## Shell开发规范
采用Google的Shell代码风格：  
https://google.github.io/styleguide/shell.xml
### 开发计划说明
V1.0  
在1.0版本中虽然强制分了模块，但每个脚本都写的很冗余，并且重复项目太多，每个文件都区分了系统，其实这样非常不利于后期维护。  
V2.0  
计划重新开发2.0版本，严格采用Google的开发规范重写每个模块。计划增加如下：  
1、增加全局配置项。  
2、每个文件内判断系统版本。  
3、每个脚本上增加无人应答模式以及选择项提供智能选择。  
4、增加全局记忆配置功能，配合自定义选择配置项进行执行。  
5、增加选择配置项生成自定义脚本。  
6、增加jenkins结合调用。  
7、增加一键部署功能，与jenkins无缝对接。  
8、增加ansible的远程功能（重点）
V3.0  
计划增加Web界面配置，采用Python开发Web，实现一键部署  
1、增加Web界面配置，快速一键安装环境  
2、增加相关软件的配置界面，比如nginx等  
3、增加批量环境部署，以前在jenkins做的实现搬到了此界面，输入一个ip自动初始化，甚至可以实现批量初始化集群环境。  
#### 如果也有兴趣实现以上计划，非常期待你的加入