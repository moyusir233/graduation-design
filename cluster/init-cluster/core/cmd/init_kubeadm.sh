#!/bin/sh
#利用kubeadm创建kubernetes集群
cd /root/k8s-install/core
kubeadm init --config kubeadm-config.yaml > init-master.log