# observability

Deploys a monitoring + logging stack into an existing EKS cluster, all in the `monitoring` namespace.

State bucket: `nshavandin-observability-state`. Requires a running cluster — set `CLUSTER_NAME` (looked up via `data.aws_eks_cluster`).

## Unit (`study/observability`)

Single unit → `modules/observability`, which installs three Helm releases:

| Release | Chart | Purpose |
|---------|-------|---------|
| kube-prometheus-stack | `prometheus-community/kube-prometheus-stack` | Prometheus, Grafana, Alertmanager, exporters |
| Loki | `grafana/loki` | log storage (SingleBinary mode + MinIO) |
| Alloy | `grafana/alloy` | log collector (DaemonSet) → pushes to Loki |

Each release is fed its own values file in the module: `prometheus-stack-values.yaml`, `loki-values.yaml`, `alloy-values.yaml`.

## Usage

```bash
export AWS_PROFILE=terraform-private-aws
export CLUSTER_NAME=<your-eks-cluster>

cd observability
terragrunt apply
```

Access Grafana / Loki locally:

```bash
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
kubectl port-forward -n monitoring svc/loki 3100:80
```

## Notes / gotchas

- **Loki uses `deploymentMode: SingleBinary`** (not `Monolithic`). In the loki chart 7.x, `Monolithic` does not render the engine StatefulSet — only gateway/cache/minio come up and the gateway 502s. Keep it `SingleBinary`.
- `loki.auth_enabled: false` for single-tenant — otherwise every read (Grafana/curl) and write (Alloy) must send an `X-Scope-OrgID` header.
- Alloy collects pod logs only from the namespaces listed in `alloy-values.yaml` (`discovery.kubernetes` → `namespaces`). Alloy config is written in **Alloy syntax** (comments are `//`, not `#`).
- Grafana Ingress carries a `cert-manager.io/cluster-issuer` annotation — a valid certificate additionally requires cert-manager + a matching `ClusterIssuer` + ingress-nginx + a DNS record (see `app/`).
- MinIO backing Loki is the chart's built-in (deprecated) instance — fine for a pet project; use a real S3 bucket for anything serious.
