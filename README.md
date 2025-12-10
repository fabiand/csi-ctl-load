# csi-ctl-load

This will create N pods with N PVCs requetsing fresh 1GB PVs.
Primary prupose is to trigger CSI control plane calls, and LUN path map/unmapping on the node level.

After the test, the output of `test.sh` should not include `CORRUPTION DETECTED`. if it does, then some corruption of the underlying PVs happened. Unless there is a bug in this script.

# Run

A a Linux workstation

    $ oc login …
    $ bash test.sh  # Using default storage class
    #
    $ bash test.sh whatever-customer-storage  # To use a specific storage class


## Triggering a corruption

If you want to test that the script works correct, then oyu can force a corruption by running:

    while true ; do oc exec csi-ctl-load-1 -- bash -xc "echo 1 > /dev/csi-pvc ; sha256sum /dev/csi-pvc" ; done

# Monitor

    $ watch "oc get -f set.yaml ; oc get pods | head ; oc get pvc | head"

## promql

See PVs getting created

    delta(pv_collector_total_pv_count[1m])

Then monitor the waves of disks per node

    sum(node_disk_info)

# Related

- https://gist.github.com/akalenyu/00f51e4608912b4672f3e26d36b9e202
