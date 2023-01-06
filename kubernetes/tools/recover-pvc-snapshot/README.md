# Recovery PVC Snapshot
Tool to take a DigitalOcean volume snapshot and recover it onto an existing PVC.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)

# Overview
One way or another there could be a situation where one needs to recover a DigitalOcean snapshot to an already existing persistent volume claim.

# Instructions
Follow these sections to copy data from a DigitalOcean volume snapshot to a PVC in a cluster:

1. Find the ID of the DigitalOcean volume snapshot:
   ```
   doctl compute snapshot list
   ```
2. Create a copy of [`overlay/kustomization.example.yaml`](./overlay/kustomization.example.yaml) named `kustomization.yaml`:
   - Replace `namePrefix`: With a name describing what snapshot your are restoring, this will be a prefix for all created Kubernetes resource names (Only include lowercase letters and slashes, ideally end it with a dash), replace `<namePrefix>` in the instructions with this value
   - Replace `patches.0.patch.value`: With your ID of snapshot ID
3. Apply the Kubernetes manifests to create the resources used to restore the volume:
   ```
   kustomize build ./overlay | kubectl apply -f -
   ```
4. Copy the contents of the restored volume to your computer:
   ```
   kubectl -n pvc-restore cp <namePrefix>restore-pod:/mnt ./restored-volume
   ```
   Then copy the content to the volume attached to the pod you were trying to restore into:
   ```
   kubectl cp ./restored-volume <the pod you want to restore to>:<pod restore path>
   ```
   Replace `<the pod you want to restore to>` and `<pod restore path>` as appropriate.
5. When you are done with your restore process delete the temporary Kubernetes resources:
   ```
   kustomize build ./overlay | kubectl delete -f -
   ```

References used to this section:

- [DigitalOcean Instructions](https://docs.digitalocean.com/products/kubernetes/how-to/import-snapshot/)

DigitalOcean saves volumes after they 