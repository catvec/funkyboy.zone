# Kubernetes
A Kubernetes cluster.

# Table Of Contents
- [Overview](#overview)
- [Operations](#operations)

# Overview
A Kubernetes cluster hosted on DigitalOcean.

# Operations
## Changing Default Node Pool
Due to [a bug](https://github.com/digitalocean/terraform-provider-digitalocean/issues/424) with the DigitalOcean Terraform provider you cannot change the node size of the default worker pool without re-creating the cluster. This is not a limitation of the DigitalOcean API, in fact that DigitalOcean API doesn't even have the concept of a default node pool.

The community [has found a workaround](https://github.com/digitalocean/terraform-provider-digitalocean/issues/424#issuecomment-1440089977):

1. Create a new `digitalocean_kubernetes_node_pool` resource with the specifications of your soon to be new default node pool. This can be done by setting the `additional_node_pools` input variable for this module
2. Terraform apply so the new node pool is created
3. Go into the DigitalOcean console and remove the `terraform:default-node-pool` label from your current default node pool. Then add it to your new default node pool
4. Remove the all DigitalOcean Kubernetes resources from the Terraform state.  
   Right now for the overall project this can be done by running:
   ```
   cd terraform
   terraform state rm -state ../secret/terraform/compute/terraform.tfstate 'module.all_cloud.module.kubernetes_cluster.digitalocean_kubernetes_node_pool.node_pool["worker_pool_b"]'
   terraform state rm -state ../secret/terraform/compute/terraform.tfstate module.all_cloud.module.kubernetes_cluster.digitalocean_kubernetes_cluster.cluster
   ```

   Be sure to substitute `worker_pool_b` with the map key of your new worker pool.
5. Go into the DigitalOcean dashboard and delete the old default node pool
6. Import the Kubernetes cluster back into the Terraform state:
   Right now for the overall project this can be done by running
   ```
   cd terraform/compute
   terraform import -state ../../secret/terraform/compute/terraform.tfstate module.all_cloud.module.kubernetes_cluster.digitalocean_kubernetes_cluster.cluster <DO K8S CLUSTER ID>
   ```
