#!/bin/bash
#该脚本用于拉取git仓库代码，并依据环境变量执行go test
rm -rf "${PROJECT_DIR}"
git clone "${PROJECT_REPO_ADDRESS}" -b "${BRANCH}" --single-branch --recurse-submodules
cd "${PROJECT_DIR}" || exit
if [ "${TEST_COVER_ENABLE}" == "enable" ]; then
  go test -v -timeout "${TEST_TIMEOUT}" -run ^\("${TEST_PREFIX}"\) -coverprofile coverprofile.out -coverpkg "${TEST_COVER_PKG}" ./...
  go tool cover -func=coverprofile.out
  go tool cover -html=coverprofile.out -o report.html
  mv report.html ..
else
  go test -v -timeout "${TEST_TIMEOUT}" -run ^\("${TEST_PREFIX}"\) ./...
fi