# centos-shell
CentOS常用Shell  
注意：如无特殊标识，默认运行环境为CentOS 7+
## 使用前需要设置脚本可执行权限
```shell
chmod +x xxx.sh
```
## 使用所有脚本之前必须新建好文件夹
```shell
bash directory/init-directory.sh
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