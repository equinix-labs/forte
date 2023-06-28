#!/bin/bash

sudo kubeadm reset -y

sudo apt purge kubectl kubeadm kubelet kubernetes-cni -y
sudo apt autoremove
sudo rm -fr /etc/kubernetes/
sudo rm -fr ~/.kube/
sudo rm -fr /var/lib/etcd
sudo rm -rf /var/lib/cni/

sudo systemctl daemon-reload

sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F && sudo iptables -X

# remove all running docker containers
docker rm -f `docker ps -a | grep "k8s_" | awk '{print $1}'`
