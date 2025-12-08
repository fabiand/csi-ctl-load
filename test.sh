#!/usr/bin/bash

set -ex

N_MAX=5
for N in $(seq 1 $N_MAX);
do
  echo "# Iteration $N of $N_MAX"
  oc apply -f manifests/set.yaml
  oc wait --for jsonpath=.status.availableReplicas=100 -f manifests/set.yaml --timeout 5m
  kubectl patch statefulset csi-ctl-load --patch '{"spec": {"replicas": 0}}'
done

oc delete -f manifests/set.yaml --wait
