#!/bin/bash
sed -i -E -e '/^datasource_list:.*/s/.*/datasource_list: [NoCloud]/' /etc/cloud/cloud.cfg
rm /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
rm /etc/network/interfaces
rm /etc/networks
apt purge -y ifupdown

apt update -y
apt install vlan -y

vconfig add bond0 1774

ip link set up dev bond0.1774
ip address add 192.168.55.21/24 dev bond0.1774
ip route add 172.23.0.0/16 via 192.168.55.1 dev bond0.1774
ip route add 10.126.0.0/16 via 192.168.55.1 dev bond0.1774
ip route add 173.29.5.0/24 via 192.168.55.1 dev bond0.1774

swapoff -a
apt update -y
apt install python3-pip -y
wget https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
mv get-helm-3 get_helm.sh
chmod 0700 /get_helm.sh
/get_helm.sh --version v3.5.2
apt update -y
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` test"
apt update -y
apt install docker-ce -y
usermod -aG docker $USER
apt update -y
apt install -y apt-transport-https ca-certificates curl
su - -c  "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
su - -c "echo deb http://apt.kubernetes.io/ kubernetes-xenial main | tee /etc/apt/sources.list.d/kubernetes.list"
su - -c "apt-get update"
apt install -y kubelet=1.20.0-00 kubeadm=1.20.0-00 kubectl=1.20.0-00
kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

sleep 30

wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

sleep 120

cp -r /root/.kube /
kubectl apply -f /kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/master:NoSchedule-

helm repo add bitnami https://charts.bitnami.com/bitnami
helm install forte-nginx bitnami/nginx

git clone https://github.com/oberzin/iotedge.git
