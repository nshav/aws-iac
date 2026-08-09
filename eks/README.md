# eks

Provisions the network and the EKS cluster. This is the foundation stack — `app/` and `observability/` deploy *into* the cluster created here.

State bucket: `nshavandin-eks-state`. Cloud: AWS.

## Units (`study/`)

| Unit | Module | Creates |
|------|--------|---------|
| `vpc` | `modules/vpc` | VPC, public/private subnets, Internet Gateway, NAT Gateway + EIP, route tables |
| `iam` | `modules/iam` | IAM roles for the EKS control plane and node group (+ policy attachments) |
| `eks` | `modules/eks` | `aws_eks_cluster` + `aws_eks_node_group` |

## Dependencies

```
vpc ─┐
     ├─> eks     (eks consumes subnet IDs from vpc, role ARNs from iam)
iam ─┘
```

The `eks` unit declares `dependency` on both `vpc` and `iam` and wires their outputs via `inputs` (subnet IDs, role ARNs). `mock_outputs` are provided so `plan`/`validate` work before the dependencies are applied.

## Usage

```bash
export AWS_PROFILE=terraform-private-aws
export AWS_DEFAULT_REGION=us-east-1

cd eks
terragrunt run --all apply        # applies vpc, iam, then eks in order
```

Per-unit:

```bash
cd study/vpc && terragrunt apply
cd ../iam   && terragrunt apply
cd ../eks   && terragrunt apply
```

After the cluster is up, grab kubeconfig:

```bash
aws eks update-kubeconfig --name <cluster-name> --region us-east-1 --profile terraform-private-aws
```

## Teardown

Destroy in reverse (`eks` → `iam`/`vpc`). Before destroying `vpc`, remove any Kubernetes `LoadBalancer` Services / Ingresses first — they create ELB/ENI/EIP outside Terraform and will otherwise block subnet and Internet Gateway deletion with `DependencyViolation`.
