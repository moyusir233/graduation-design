#!/bin/sh
#导入kubernetes集群所需的docker镜像
dir=/root/k8s-install/core/images
cd $dir
for i in $(ls $dir); do
  docker load -i "$i"
done
