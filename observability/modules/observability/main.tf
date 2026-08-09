resource "helm_release" "kube-prometheus-stack" {
  atomic     = true
  name       = var.kps_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace
  create_namespace = true

  values = [
    "${file("prometheus-stack-values.yaml")}"
  ]
}


resource "helm_release" "loki" {
  atomic     = true
  name       = var.loki_name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = var.namespace
  create_namespace = true

  values = [
    "${file("loki-values.yaml")}"
  ]
}

resource "helm_release" "alloy" {
  atomic     = true
  name       = var.alloy_name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  namespace  = var.namespace
  create_namespace = true

  values = [
    "${file("alloy-values.yaml")}"
  ]
}