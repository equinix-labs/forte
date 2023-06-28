#!/bin/bash

export GNB=$(kubectl get pods --namespace f5gc -l "component=gnb" -o jsonpath="{.items[0].metadata.name}")

echo "GNB = " $GNB
