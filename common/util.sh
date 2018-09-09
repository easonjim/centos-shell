#!/bin/bash
#
# 工具类

#######################################
# 输出标准日志
# Globals:
# Arguments:
#   $1:日志信息
# Returns:
#   None
#######################################
util::log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S:%s')]-[INFO]: $@" >&1
}

#######################################
# 输出错误日志
# Globals:
# Arguments:
#   $1:日志信息
# Returns:
#   None
#######################################
util::log_err() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S:%s')]-[ERROR]: $@" >&2
}

#######################################
# 检查是否为root用户，脚本必须在root权限下运行
# Globals:
#   None
# Arguments:
#   Node
# Returns:
#   None
#######################################
util::check_root() {
    if [[ "$(whoami)" != "root" ]]; then
        echo "please run this script as root !" >&2
        exit 1
    fi
}

#######################################
# 检查系统版本
# User:
#   $(util::check_os_version)
# Globals:
#   None
# Arguments:
#   Node
# Returns:
#   6/7
#######################################
util::check_os_version(){
    echo `rpm -q centos-release|cut -d- -f3`
}