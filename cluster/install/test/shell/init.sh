#!/bin/bash
#配置git使用ssh拉取gitee私有仓库代码
git config --global url."git@gitee.com:".insteadOf https://gitee.com/
git clone "${PROJECT_REPO_ADDRESS}" -b "${BRANCH}" --single-branch
cd "${PROJECT_DIR}" || exit
#配置go拉取gitee代码时不使用代理
go env -w GOPRIVATE=gitee.com
go env -w GOPROXY=https://goproxy.cn,https://goproxy.io,direct
go test -v -run ^\("${TEST_PREFIX}"\) -coverprofile coverprofile.out -coverpkg "${TEST_PKG}" ./...
go tool cover -func=coverprofile.out
go tool cover -html=coverprofile.out -o report.html
mv report.html ..
cd .. && rm -rf "${PROJECT_DIR}"