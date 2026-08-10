# aws-iac

Personal learning project: an AWS EKS platform managed with **Terragrunt + OpenTofu**, split into independent stacks — the cluster, an ingress/WAF + demo app layer, and an observability stack.

## Stacks

| Stack | Purpose | State bucket |
|-------|---------|--------------|
| [`s3-bucket/`](s3-bucket) | Creates the S3 buckets used as remote-state backends | local state |
| [`eks/`](eks) | VPC + EKS cluster (public Terraform registry modules) | `nshavandin-eks-state` |
| [`app/`](app) | cert-manager, Wallarm/F5 ingress controller, demo backend (httpbin + Ingress) | `nshavandin-app-state` |
| [`observability/`](observability) | kube-prometheus-stack, Loki, Grafana Alloy | `nshavandin-observability-state` |

Each stack is a directory with its own `root.hcl` (shared backend + provider generation) and a `study/` folder holding one **unit** (`terragrunt.hcl`) per deployable component.

## Prerequisites

- [OpenTofu](https://opentofu.org/) `>= 1.14`
- [Terragrunt](https://terragrunt.gruntwork.io/) — new CLI (`run --all`, `--queue-include-dir` / `--queue-exclude-dir`)
- AWS CLI with a working profile, `kubectl`, `helm`

## Configuration (environment variables)

All stacks read config from the environment via `get_env(...)`:

| Variable | Used by | Default | Meaning |
|----------|---------|---------|---------|
| `AWS_PROFILE` | all | `terraform-private-aws` | AWS CLI profile |
| `AWS_DEFAULT_REGION` | all | `us-east-1` | AWS region |
| `CLUSTER_NAME` | all | — (required) | EKS cluster name — created by `eks`, looked up by `app`/`observability` |
| `HTTPBIN_HOSTNAME` | `app` | `httpbin.requestsbin.online` | hostname for the httpbin Ingress |
| `GRAFANA_HOSTNAME` | `observability` | — | hostname for the Grafana Ingress |
| `GRAFANA_ADMIN_PASSWORD` | `observability` | — (secret) | Grafana admin password |

`app` and `observability` deploy *into* an existing cluster (looked up via `data.aws_eks_cluster` by `CLUSTER_NAME`), so `eks` must be applied first.

## Deploy order

```
1. s3-bucket/                     # once — creates the remote-state buckets
2. eks/                           # vpc -> eks (dependency order handled by Terragrunt)
3. app/  and  observability/      # require a running cluster (CLUSTER_NAME)
```

```bash
export AWS_PROFILE=terraform-private-aws
export AWS_DEFAULT_REGION=us-east-1
export CLUSTER_NAME=nsha-study

cd eks && terragrunt run --all apply
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_DEFAULT_REGION" --profile "$AWS_PROFILE"
```

## Notes

- Remote state: S3 with `use_lockfile = true` (native locking, no DynamoDB).
- `provider.tf` / `backend.tf` / `data.tf` are **generated** by each `root.hcl` — never edit the copies in `.terragrunt-cache`. After changing `root.hcl` or a module, clear the unit's `.terragrunt-cache` if stale output persists.
- **Teardown** is the reverse of deploy. Delete Kubernetes `LoadBalancer`/`Ingress` objects **before** destroying `eks/` — otherwise orphaned ELB/ENI/security-groups block VPC deletion (`DependencyViolation`). k8s-created security groups (`k8s-elb-*`) sometimes linger even after the ELB is gone and must be removed by hand.
