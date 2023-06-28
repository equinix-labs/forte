#!/bin/bash

pod_tag=$1

pod_name=$(kubectl -n f5gc get pods -l "nf=$pod_tag" -o jsonpath="{.items[0].metadata.name}")

echo "Deleteing pod " $pod_name

kubectl -n f5gc delete pod $pod_name


