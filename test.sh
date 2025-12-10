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
  oc wait --for jsonpath=.status.readyReplicas=100 -f $MANIFEST --timeout 15m
  oc get pods -o NAME | xargs -P 5 -i -- bash -c "oc logs {} | grep -s \"CK FAILED\" && { echo CORRUPTION DETECTED by pod {} ; oc logs {} | sed \"s/^/> /\" ; }" || :
  kubectl patch statefulset csi-ctl-load --patch '{"spec": {"replicas": 0}}'
  oc wait --for jsonpath=.status.replicas=0 -f $MANIFEST --timeout 15m
done

oc delete -f $MANIFEST --wait
