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
#安装protoc编译需要的插件
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
go install github.com/go-kratos/kratos/cmd/kratos/v2@latest
go install github.com/go-kratos/kratos/cmd/protoc-gen-go-http/v2@latest
go install github.com/go-kratos/kratos/cmd/protoc-gen-go-errors/v2@latest
go install github.com/google/gnostic/cmd/protoc-gen-openapi@v0.6.1