#!/bin/bash


export POD=$(kubectl get pods --namespace f5gc -l "nf=$1" -o jsonpath="{.items[0].metadata.name}")

kubectl -n f5gc exec -it $POD -- tail -f /free5gc/log/free5gc.log
