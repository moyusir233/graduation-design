#!/bin/bash
#该代码用于开启指定git仓库go代码的远程debug模式

rm -rf "${PROJECT_DIR}"
git clone "${PROJECT_REPO_ADDRESS}" -b "${BRANCH}" --single-branch --recurse-submodules
cd "${PROJECT_DIR}" || exit
dlv test --headless --listen=:2345 --api-version=2 --accept-multiclient "${TEST_PKG}" -- -test.v -test.run ^\("${TEST_PREFIX}"\)
