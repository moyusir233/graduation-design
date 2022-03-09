#!/bin/bash
#该脚本用于初始化auto-test-server的环境

#配置go拉取gitee代码时不使用代理
go env -w GOPRIVATE=gitee.com
#配置go拉取除了gitee以外的代码时使用代理
go env -w GOPROXY=https://goproxy.cn,https://goproxy.io,direct
#配置git使用ssh拉取gitee私有仓库代码
git config --global url."git@gitee.com:".insteadOf https://gitee.com/
#下载开启远程debug的dlv程序
go install github.com/go-delve/delve/cmd/dlv@latest