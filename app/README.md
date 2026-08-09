# app

Deploys the ingress/WAF layer and a demo backend into an existing EKS cluster: cert-manager, the Wallarm (F5 NGINX) ingress controller, and httpbin behind an Ingress.

State bucket: `nshavandin-app-state`. Requires a running cluster — set `CLUSTER_NAME` (looked up via `data.aws_eks_cluster`).

## Units (`study/`)

| Unit | Module | Creates |
|------|--------|---------|
| `cert-manager` | `modules/cert-manager` | cert-manager Helm release (+ CRDs) and a `ClusterIssuer` |
| `f5-ingress-controller` | `modules/f5-ingress-controller` | Wallarm ingress controller (Helm), its namespace, and the httpbin `Ingress` |
| `backend` | `modules/backend` | httpbin `Deployment` + `Service` |

## Dependencies & apply order

`f5-ingress-controller` depends on `cert-manager` (`skip_outputs = true`) — cert-manager must be applied first so the `ClusterIssuer`/CRD types exist when the ingress unit plans.

```bash
export AWS_PROFILE=terraform-private-aws
export CLUSTER_NAME=<your-eks-cluster>
export HTTPBIN_HOSTNAME=httpbin.requestsbin.online

cd app
terragrunt run --all apply
# or a subset:
terragrunt run --all apply --queue-exclude-dir study/backend
```

Per-unit order: `cert-manager` → `f5-ingress-controller` → `backend`.

## Configuration

| Variable | Default | Meaning |
|----------|---------|---------|
| `CLUSTER_NAME` | — (required) | EKS cluster to deploy into |
| `HTTPBIN_HOSTNAME` | `httpbin.requestsbin.online` | host for the httpbin Ingress (injected into the manifest) |
| `var.cert_manager_version` | `1.21.1` | cert-manager chart version |
| `var.wallarm_ic_version` | `6.13.0` | Wallarm ingress chart version |

## Notes / gotchas

- **Wallarm chart is pinned to `6.13.0`.** Versions `>= 7.0.0` ship a `values.schema.json` with remote `$ref`s that break under Helm 3.16+ (the helm provider v3). Do not bump without addressing that.
- The Wallarm API token currently lives in plaintext in `modules/f5-ingress-controller/values.yaml` — **move it to a Secret and rotate it**; do not commit real tokens.
- File references in manifests use `${path.module}/...` so they resolve inside the Terragrunt cache. `HTTPBIN_HOSTNAME` is injected via `templatefile` — plain `file()` would leave `${...}` literal and fail k8s validation.
- TLS for Grafana/httpbin needs the full chain (ingress-nginx or the controller's IngressClass + a reachable public IP + DNS A record) before cert-manager can complete the ACME HTTP-01 challenge.
