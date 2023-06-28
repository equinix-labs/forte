#!/bin/bash

echo "Uninstalling Helm release"
helm -n f5gc uninstall f5gc-udm 
helm -n f5gc uninstall f5gc-udr
helm -n f5gc uninstall f5gc-pcf 
helm -n f5gc uninstall f5gc-ausf 
helm -n f5gc uninstall f5gc-nssf 
helm -n f5gc uninstall f5gc-webui
helm -n f5gc uninstall f5gc-amf
helm -n f5gc uninstall f5gc-smf
helm -n f5gc uninstall f5gc-nrf

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
helm -n f5gc install f5gc-nrf ~/f5gc-ne/cp/free5gc-nrf/ > /dev/null
helm -n f5gc install f5gc-smf ~/f5gc-ne/cp/free5gc-smf/ > /dev/null
helm -n f5gc install f5gc-amf ~/f5gc-ne/cp/free5gc-amf/ > /dev/null
helm -n f5gc install f5gc-udm ~/f5gc-ne/cp/free5gc-udm/ > /dev/null
helm -n f5gc install f5gc-udr ~/f5gc-ne/cp/free5gc-udr/ > /dev/null
helm -n f5gc install f5gc-pcf ~/f5gc-ne/cp/free5gc-pcf/ > /dev/null
helm -n f5gc install f5gc-ausf ~/f5gc-ne/cp/free5gc-ausf/ > /dev/null
helm -n f5gc install f5gc-nssf ~/f5gc-ne/cp/free5gc-nssf/ > /dev/null
helm -n f5gc install f5gc-webui ~/f5gc-ne/cp/free5gc-webui/ > /dev/null

sleep 10

export NRF=$(kubectl -n f5gc get pods -l "nf=nrf" -o jsonpath="{.items[0].metadata.name}")
export SMF=$(kubectl -n f5gc get pods -l "nf=smf" -o jsonpath="{.items[0].metadata.name}")
export AMF=$(kubectl -n f5gc get pods -l "nf=amf" -o jsonpath="{.items[0].metadata.name}")
export UDM=$(kubectl -n f5gc get pods -l "nf=udm" -o jsonpath="{.items[0].metadata.name}")
export UDR=$(kubectl -n f5gc get pods -l "nf=udr" -o jsonpath="{.items[0].metadata.name}")
export PCF=$(kubectl -n f5gc get pods -l "nf=pcf" -o jsonpath="{.items[0].metadata.name}")
export AUSF=$(kubectl -n f5gc get pods -l "nf=ausf" -o jsonpath="{.items[0].metadata.name}")
export NSSF=$(kubectl -n f5gc get pods -l "nf=nssf" -o jsonpath="{.items[0].metadata.name}")
export WEB=$(kubectl -n f5gc get pods -l "nf=webui" -o jsonpath="{.items[0].metadata.name}")

echo "Checking Control Plane Pods"
kubectl -n f5gc get pods

while [[ $(kubectl -n f5gc get pod $NRF |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $SMF |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $AMF |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $UDM |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $UDR |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $PCF |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $AUSF |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $NSSF |grep 'Running') == ""  && \
         $(kubectl -n f5gc get pod $WEB |grep 'Running') == "" ]]; do
	echo "Still coming up..."
	kubectl -n f5gc get pods
	echo "####################"
        sleep 3
done


echo "Checking all pods"
kubectl get pods --all-namespaces

echo "Waiting..."
sleep 15

echo "Resetting SMF Pod Again"
kubectl -n f5gc delete pod $SMF
export SMF=$(kubectl get pods --namespace f5gc -l "nf=smf" -o jsonpath="{.items[0].metadata.name}")

echo "Waiting..."
sleep 15
kubectl -n f5gc get pods
