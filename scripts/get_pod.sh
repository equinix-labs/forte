#!/bin/bash

pod_tag=$1

export POD=$(kubectl -n f5gc get pods -l "nf=$pod_tag" -o jsonpath="{.items[0].metadata.name}")

echo "Pod Name = " $POD


