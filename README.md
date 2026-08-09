# aws-iac

Personal learning project: an AWS EKS platform managed with **Terragrunt + OpenTofu**, split into independent stacks. Provisions the cluster, an ingress/WAF layer, and an observability stack.

## Stacks

| Stack | Purpose | State bucket |
|-------|---------|--------------|
| [`s3-bucket/`](s3-bucket) | Creates the S3 buckets used as remote state backends | local state |
| [`eks/`](eks) | VPC, IAM roles, and the EKS cluster itself | `nshavandin-eks-state` |
| [`app/`](app) | cert-manager, Wallarm/F5 ingress controller, demo backend (httpbin) | `nshavandin-app-state` |
| [`observability/`](observability) | kube-prometheus-stack, Loki, Grafana Alloy | `nshavandin-observability-state` |

Each stack is a directory with its own `root.hcl` (shared backend + provider generation) and a `study/` folder holding one **unit** (a `terragrunt.hcl`) per deployable component.

## Prerequisites

- [OpenTofu](https://opentofu.org/) `>= 1.14`
- [Terragrunt](https://terragrunt.gruntwork.io/) (new CLI — uses `run --all`)
- AWS CLI with a working profile
- `kubectl`, `helm`

## Configuration (environment variables)

All stacks read configuration from the environment (see each `root.hcl`):

| Variable | Used by | Default | Meaning |
|----------|---------|---------|---------|
| `AWS_PROFILE` | all | `terraform-private-aws` | AWS CLI profile |
| `AWS_DEFAULT_REGION` | all | `us-east-1` | AWS region |
| `CLUSTER_NAME` | `app`, `observability` | — (required) | Name of the existing EKS cluster to deploy into |
| `HTTPBIN_HOSTNAME` | `app` | `httpbin.requestsbin.online` | Hostname for the demo Ingress |

`app` and `observability` look up the cluster via `data.aws_eks_cluster` using `CLUSTER_NAME`, so the EKS cluster must exist before applying them.

## Deploy order

```
1. s3-bucket/      # once — creates the remote-state buckets
2. eks/            # vpc -> iam -> eks (dependency order handled by Terragrunt)
3. app/  and  observability/   # require a running cluster (CLUSTER_NAME)
```

Typical run (per stack):

```bash
export AWS_PROFILE=terraform-private-aws
export AWS_DEFAULT_REGION=us-east-1
export CLUSTER_NAME=<your-eks-cluster>

cd eks
terragrunt run --all apply     # or apply per-unit inside study/
```

## Notes

- Remote state: S3 with `use_lockfile = true` (native state locking, no DynamoDB).
- `provider.tf` / `backend.tf` / `data.tf` are **generated** by each `root.hcl` — do not edit the generated files in `.terragrunt-cache`.
- Teardown order is the reverse of deploy. Delete Kubernetes `LoadBalancer`/`Ingress` objects **before** destroying `eks/`, or leftover ELB/ENI/EIP will block VPC deletion.
