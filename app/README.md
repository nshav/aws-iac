# app

Deploys the ingress/WAF layer and a demo backend into an existing EKS cluster: cert-manager, the Wallarm (F5 NGINX) ingress controller, and httpbin behind an Ingress.

State bucket: `nshavandin-app-state`. Requires a running cluster — set `CLUSTER_NAME` (looked up via `data.aws_eks_cluster`).

## Units (`study/`)

| Unit | Module | Creates |
|------|--------|---------|
| `cert-manager` | `modules/cert-manager` | cert-manager Helm release (CRDs) + a `ClusterIssuer` |
| `f5-ingress-controller` | `modules/f5-ingress-controller` | Wallarm ingress controller (Helm) + its namespace |
| `backend` | `modules/backend` | httpbin `Deployment` + `Service` + `Ingress` |

## Dependencies & apply order

`f5-ingress-controller` depends on `cert-manager` (`dependency`, `skip_outputs = true`) so the `ClusterIssuer` CRD exists before it plans. `dependency` only orders `run --all` — a standalone `terragrunt apply` in one unit does **not** apply its dependencies.

```bash
export AWS_PROFILE=terraform-private-aws
export CLUSTER_NAME=nsha-study
export HTTPBIN_HOSTNAME=httpbin.requestsbin.online

cd app && terragrunt run --all apply
# subset:
terragrunt run --all apply --queue-include-dir study/backend
```

Per-unit order: `cert-manager` → `f5-ingress-controller` → `backend`.

## Configuration

| Variable | Default | Meaning |
|----------|---------|---------|
| `CLUSTER_NAME` | — (required) | EKS cluster to deploy into |
| `HTTPBIN_HOSTNAME` | `httpbin.requestsbin.online` | host for the httpbin Ingress |
| `var.wallarm_ic_version` | `6.13.0` | Wallarm ingress chart version |
| `var.cert_manager_version` | `1.21.1` | cert-manager chart version |

The httpbin manifest is rendered with `templatefile()`, injecting `hostname` (and `WALLARM_MODE`) — plain `file()` leaves `${...}` literal and fails k8s validation.

## Notes / gotchas

- **Wallarm chart pinned to `6.13.0`.** Versions `>= 7.0.0` ship a `values.schema.json` with remote `$ref`s that break under Helm 3.16+ (helm provider v3). Don't bump without addressing that.
- The Wallarm API token currently sits in plaintext in `modules/f5-ingress-controller/values.yaml` — **move it to a Secret and rotate it**; never commit real tokens.
- Manifest file refs use `${path.module}/...` so they resolve inside the Terragrunt cache (`./x.yaml` resolves against the tofu working dir, not the module).
- `kubernetes_manifest` for a CRD type (e.g. `ClusterIssuer`) needs that CRD to exist at **plan** time — hence cert-manager is a separate unit applied first. If state references a `ClusterIssuer` from a since-recreated cluster, `terragrunt state rm kubernetes_manifest.cluster_issuer` before destroy.
- TLS: cert-manager can only complete the ACME HTTP-01 challenge once there is a reachable public LB + a DNS record for the host (AWS ELB gives a DNS name → use a CNAME/Route53 alias, not an A record).
