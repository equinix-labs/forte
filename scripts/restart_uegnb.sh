#!/bin/bash

echo "Uninstalling Helm release"
helm -n f5gc uninstall f5gc-ueran

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
helm -n f5gc install f5gc-ueran ~/f5gc-ne/ueran/ > /dev/null

sleep 10

export UE=$(kubectl get pods --namespace f5gc -l "component=ue" -o jsonpath="{.items[0].metadata.name}")
export GNB=$(kubectl get pods --namespace f5gc -l "component=gnb" -o jsonpath="{.items[0].metadata.name}")

echo "Checking UE and GNB Pods"
kubectl -n f5gc get pods

while [[ $(kubectl -n f5gc get pod $UE |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $GNB |grep 'Running') == "" ]]; do
	echo "Still coming up..."
	kubectl -n f5gc get pods
	echo "####################"
        sleep 3
done


echo "Checking all pods"
kubectl get pods --all-namespaces

echo "Waiting..."
sleep 15

echo "Checking UE Mobile IP Address.."
UEIP=$(kubectl -n f5gc exec -it $UE -- ip -o -4 addr list uesimtun0 | awk '{print $4}' | cut -d/ -f1)
if [[ $UEIP != "not" ]]; then
	echo "UE Mobile IP Address = " $UEIP
	echo "Checking connectivity from UE"
        kubectl -n f5gc exec -it $UE -- ping -c 5 www.google.com -I uesimtun0
else
	echo "UE Mobile IP Address Assignement FAILED"
	echo "Restart UPF and SMF"
fi

#echo "Checking connectivity from UE"
#kubectl -n f5gc exec -it $UE -- ping -c 5 www.google.com -I uesimtun0

