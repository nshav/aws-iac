# eks

Provisions the network and the EKS cluster — the foundation stack that `app/` and `observability/` deploy into. Uses the public Terraform registry modules (not local ones).

State bucket: `nshavandin-eks-state`. Cloud: AWS.

## Units (`study/`)

| Unit | Source | Creates |
|------|--------|---------|
| `vpc` | `terraform-aws-modules/vpc/aws` `5.1.1` | VPC, public/private subnets, IGW, NAT + EIP, route tables |
| `eks` | `terraform-aws-modules/eks/aws` `20.0.0` | EKS cluster, managed node group, **and its IAM roles** |

There is no separate `iam` unit — the EKS module creates the cluster/node-group roles itself.

## Dependencies

```
vpc ──> eks     (eks consumes vpc_id + private_subnets via dependency outputs)
```

The `eks` unit declares a `dependency` on `vpc` and wires `vpc_id` / `subnet_ids` from its outputs. `mock_outputs` cover `plan`/`validate` before `vpc` is applied.

Both `vpc.name` and `eks.cluster_name` come from `CLUSTER_NAME`.

## Provider version pin ⚠️

The EKS module `20.0.0` requires **AWS provider v5** — it still uses `elastic_gpu_specifications` / `elastic_inference_accelerator`, which were removed in AWS provider v6. `root.hcl` therefore pins:

```hcl
aws = { source = "hashicorp/aws", version = "~> 5.0" }
```

If you bump the EKS module to `v21.x` (which supports provider v6), you must also raise the provider pin **and** adapt the inputs — v21 is a breaking major (renamed variables, e.g. `cluster_name` → `name`). After changing the pin, run `terragrunt init -upgrade` to refresh the lock file.

## Usage

```bash
export AWS_PROFILE=terraform-private-aws
export AWS_DEFAULT_REGION=us-east-1
export CLUSTER_NAME=nsha-study

cd eks && terragrunt run --all apply        # vpc, then eks
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_DEFAULT_REGION" --profile "$AWS_PROFILE"
```

## Teardown

Destroy in reverse (`eks` → `vpc`). Before destroying `vpc`, remove any Kubernetes `LoadBalancer` Services / Ingresses first — they create ELB/ENI/EIP/security-groups outside Terraform and otherwise block subnet and IGW deletion with `DependencyViolation`. Orphaned `k8s-elb-*` security groups may need manual deletion.
