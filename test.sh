#!/usr/bin/bash

set -ex

for N in 1 2 3;
do
  oc apply -f manifests/set.yaml
  oc wait --for jsonpath=.status.availableReplicas=100 -f manifests/set.yaml --timeout 5m
  oc delete -f manifests/set.yaml --wait
done
