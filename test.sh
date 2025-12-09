#!/usr/bin/bash

exec > >(while IFS= read -r line; do echo "[$(date -R)] $line"; done) 2>&1

set -ex

MANIFEST=manifests/set.yaml
N_MAX=5

echo "Checking if the relevant SC exists"
oc get sc ocs-storagecluster-ceph-rbd-virtualization

cat $MANIFEST

for N in $(seq 1 $N_MAX);
do
  echo "# Iteration $N of $N_MAX"
  oc apply -f $MANIFEST
  oc wait --for jsonpath=.status.readyReplicas=100 -f $MANIFEST --timeout 5m
  kubectl patch statefulset csi-ctl-load --patch '{"spec": {"replicas": 0}}'
  oc wait --for jsonpath=.status.replicas=0 -f $MANIFEST --timeout 5m
  for POD in $(oc get pods -o NAME) ; do oc logs $POD | grep FAILED ; done
done

oc delete -f $MANIFEST --wait
