# S3 Command
Runs the `s3cmd` utilitity within the cluster.

# Table Of Contents
- [Overview](#overview)
- [Instructions](#instructions)

# Overview
This isn't a persistent service which runs. Instead it is a utility for when data needs to be transfered from the Kubernetes cluster to an S3 compatible storage service (Like Digital Ocean Spaces).

# Instructions
1. Make a copy of [`conf/s3conf-example`](./conf/s3cfg-example) named `conf/s3conf`
