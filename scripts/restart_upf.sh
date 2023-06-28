#!/bin/bash

echo "Uninstalling Helm release"
helm -n f5gc uninstall f5gc-upf

while [[ $(kubectl -n f5gc get pods) != "" ]]; do
	echo "Still terminating..."
	kubectl -n f5gc get pods
	echo "####################"
	sleep 3
done

echo "Deleting NADs and Multus"
kubectl delete crd network-attachment-definitions.k8s.cni.cncf.io
kubectl -n kube-system delete ds kube-multus-ds

echo "Waiting..."
sleep 10

echo "Installing Multus and Helm Charts"
cat ./multus-cni/deployments/multus-daemonset-thick.yml | kubectl apply -f - 
helm -n f5gc install f5gc-upf f5gc-ne/upf > /dev/null

sleep 10

export UPF=$(kubectl get pods --namespace f5gc -l "nf=upf" -o jsonpath="{.items[0].metadata.name}")

echo "Checking UPF Pod"
kubectl -n f5gc get pods

while [[ $(kubectl -n f5gc get pod $UPF |grep 'Running') == "" ]]; do
	echo "Still coming up..."
	kubectl -n f5gc get pods
	echo "####################"
    sleep 3
done


echo "Checking all pods"
kubectl get pods --all-namespaces

echo "Resetting UPF Pod Again"
kubectl -n f5gc delete pod $UPF
export UPF=$(kubectl get pods --namespace f5gc -l "nf=upf" -o jsonpath="{.items[0].metadata.name}")

echo "Waiting..."
sleep 15
kubectl -n f5gc get pods
