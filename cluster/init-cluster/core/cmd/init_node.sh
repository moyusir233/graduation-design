#!/bin/sh
#初始化需要作为kubernetes节点的linux主机

#设置主机名
if [ $# -ne 2 ]; then
  echo "输入参数数量不正确"
  exit 0
fi
hostnamectl set-hostname "$1"
echo "${2} ${1}" >>/etc/hosts

#安装需要的软件
yum -y update
yum install -y conntrack ntpdate ntp ipvsadm ipset jq iptables curl sysstat libseccomp wget vim net-tools git

#关闭防火墙，启用iptables
systemctl stop firewalld && systemctl disable firewalld
yum -y install iptables-services && systemctl start iptables && systemctl enable iptables && iptables -F && service iptables save

#关闭selinux
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

#针对kubernetes调整内核相关参数
cat >kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF
mv -f kubernetes.conf /etc/sysctl.d/kubernetes.conf
sysctl -p /etc/sysctl.d/kubernetes.conf

#关闭不需要的系统服务
systemctl stop postfix && systemctl disable postfix

#配置ipvs
modprobe br_netfilter
cat >/etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

#安装docker
yum install -y yum-utils lvm2
yum-config-manager \
  --add-repo \
  http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum -y update && yum install -y docker-ce
mkdir /etc/docker
cat >/etc/docker/daemon.json <<EOF
{
    "exec-opts":["native.cgroupdriver=systemd"],
    "log-driver":"json-file",
    "log-opts":{
        "max-size":"100m"
    }
}
EOF
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload && systemctl restart docker && systemctl enable docker

#导入阿里云镜像仓库，安装kubeadm、kubelet、kubectl
cat <<EOF >/etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum -y install kubeadm-1.22.6 kubectl-1.22.6 kubelet-1.22.6
systemctl enable kubelet.service

#升级系统内核版本，并设置系统重启后的默认加载内核版本
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-lt-5.4.176-1.el7.elrepo
grub2-set-default 'CentOS Linux (5.4.176-1.el7.elrepo.x86_64) 7 (Core)'
reboot
