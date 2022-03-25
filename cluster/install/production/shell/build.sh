#!/bin/bash
# 初始化应用部署的环境
# 配置go拉取gitee代码时不使用代理
go env -w GOPRIVATE=gitee.com
# 配置go拉取除了gitee以外的代码时使用代理
go env -w GOPROXY=https://goproxy.cn,https://goproxy.io,direct
# 配置git使用ssh拉取gitee私有仓库代码
git config --global url."git@gitee.com:".insteadOf https://gitee.com/

# 拉取项目代码，结合挂载进容器的生成的代码文件进行编译，并将生成的二进制可执行程序复制到与应用运行容器的共享volume目录/app中
git clone "${PROJECT_REPO_ADDRESS}" -b "${PROJECT_BRANCH}" --single-branch
cd "${PROJECT_DIR}" || exit
# 使用不经过alias的cp指令，强制令生成的代码文件覆盖原始的代码文件
/bin/cp -f /generated-code/*.proto "${PROJECT_API_DIR}"
/bin/cp -f /generated-code/*.go "${PROJECT_SERVICE_DIR}"
make init && make api && make build || exit
cp bin/"$(ls bin)" /app/server