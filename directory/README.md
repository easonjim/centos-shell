# 服务器部署标准目录
注意：目录名统一为小写；劲量避免出现横杠但不是必须；目录遵循Java开发规范使用单数，劲量避免但不是必须。  
强制：目录的命名必须清晰明了。
```shell
/data  
```
文件统一挂载在data级别下面，注意：此目录为第二块硬盘挂载，非系统盘目录。当更换系统时，此目录不可删除，直接附加在新系统即可使用。
## 软件
```shell
/data/service  
```
此目录用于存放软件，也就是默认安装的软件，有如下必须：
```shell
java
node
nginx
tomcat
rsync
```
说明：
- 默认软件后面不带版本号
- 默认为主流版本，假如后续需要增加相同软件，比如升级JDK从1.7到1.8时，那么目录命名为：java_1.8.0_40_6，可以看出很清晰的知道这个java是什么版本
- nginx_base和tomcat_base为软件的公共配置文件
- nginx_vhost用于存放域名
- common_conf公共配置文件，可以是任意软件的配置
## 应用
```shell
/data/webapp
```
此目录用于存放开发的应用，可以按网址分目录，也可以自定义名称。
## 日志
```shell
/data/weblog
```
此目录用于存放软件和应用的日志。  
强制：必须有以下主要目录。
```shell
/data/weblog/nginx --nginx访问日志、错误日志等，可以细分目录也可以不用
/data/weblog/nginx/default --nginx默认访问日志，使用软链接到nginx默认目录： ln -s /data/weblog/nginx/default /data/service/nginx/log，注意：前提先删除log目录
/data/weblog/tomcat --tomcat访问日志、错误日志等，需要细分目录
/data/weblog/business --应用逻辑日志，需要细分目录
```
## 用户权限
- data目录隶属于www-data组
- 要操作data目录的用于都加入到www-data组
- 应用安装时采用root用户，安装好后注意把目录权限切换到www-data
- 注意：类似PostgreSQL或者MySQL这些，有专门的用户组，这些不用变更
- 用户可以拥有sudo权限