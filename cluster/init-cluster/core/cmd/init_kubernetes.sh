#!/bin/sh
#kubernetes安装完毕后，创建kubernetes命名空间以及初始化一些组件

#创建测试用的命名空间
kubectl create namespace test
#为test命名空间的默认serviceAccount授权
kubectl create rolebinding admin --clusterrole=admin --serviceaccount=test:default