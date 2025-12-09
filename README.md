# csi-ctl-load


# Deploy

    $ oc apply -f manifests/set.yaml

# Monitor

    $ watch "oc get -f set.yaml ; oc get pods | head ; oc get pvc | head"

## promql

See PVs getting created

    delta(pv_collector_total_pv_count[1m])

Then monitor the waves of disks per node

    sum(node_disk_info)
