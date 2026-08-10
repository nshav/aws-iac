# observability

Deploys a monitoring + logging stack into an existing EKS cluster, all in the `monitoring` namespace.

State bucket: `nshavandin-observability-state`. Requires a running cluster — set `CLUSTER_NAME` (looked up via `data.aws_eks_cluster`).

## Unit (`study/observability`)

Single unit → `modules/observability`, three Helm releases:

| Release | Chart | Purpose |
|---------|-------|---------|
| kube-prometheus-stack | `prometheus-community/kube-prometheus-stack` | Prometheus, Grafana, Alertmanager, exporters |
| Loki | `grafana/loki` | log storage (SingleBinary mode + built-in MinIO) |
| Alloy | `grafana/alloy` | log collector (DaemonSet) → pushes to Loki |

Values files: `prometheus-stack-values.yaml`, `loki-values.yaml`, `alloy-values.yaml`.

## Templating

`prometheus-stack-values.yaml` contains placeholders and is rendered with `templatefile()` (loki/alloy use plain `file()` — no placeholders). All keys must be provided or `templatefile` errors:

| Placeholder | From env |
|-------------|----------|
| `GRAFANA_HOSTNAME` | `GRAFANA_HOSTNAME` |
| `GRAFANA_ADMIN_PASSWORD` | `GRAFANA_ADMIN_PASSWORD` (secret) |
| `CLUSTER_NAME` | `CLUSTER_NAME` |
| `AWS_DEFAULT_REGION` | `AWS_DEFAULT_REGION` |
| `SLACK_HOOK` | `SLACK_HOOK` (optional, Alertmanager) |

## Usage

```bash
export AWS_PROFILE=terraform-private-aws
export CLUSTER_NAME=nsha-study
export GRAFANA_HOSTNAME=grafana.requestsbin.online
export GRAFANA_ADMIN_PASSWORD=...

cd observability && terragrunt apply
```

Access locally:

```bash
kubectl port-forward -n monitoring svc/prometheus-stack-grafana 3000:80
kubectl port-forward -n monitoring svc/loki 3100:80
```

## Notes / gotchas

- **Loki uses `deploymentMode: SingleBinary`** (not `Monolithic`). In loki chart 7.x, `Monolithic` doesn't render the engine StatefulSet — only gateway/cache/minio, and the gateway 502s. Keep `SingleBinary`.
- `loki.auth_enabled: false` for single-tenant — otherwise every read (Grafana/curl) and write (Alloy) must send `X-Scope-OrgID`.
- Alloy collects pod logs only from namespaces listed in `alloy-values.yaml`; its config is **Alloy syntax** (comments are `//`, not `#`).
- Grafana Ingress carries `cert-manager.io/cluster-issuer` — a real cert also needs cert-manager + a matching `ClusterIssuer` + an ingress controller + a DNS record (see `app/`).
- Built-in MinIO backing Loki is the chart's deprecated instance — fine for a pet project; use a real S3 bucket otherwise.
