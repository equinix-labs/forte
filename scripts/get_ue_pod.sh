#!/bin/bash

export UE=$(kubectl get pods --namespace f5gc -l "component=ue" -o jsonpath="{.items[0].metadata.name}")

echo "UE = " $UE
