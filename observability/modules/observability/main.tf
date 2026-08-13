resource "helm_release" "kube-prometheus-stack" {
  atomic     = false
  name       = var.kps_name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace
  create_namespace = true

  values = [
    templatefile("${path.module}/prometheus-stack-values.yaml", {
      cluster_name           = var.cluster_name
      aws_region             = var.aws_region
      grafana_admin_password = var.grafana_admin_password
      grafana_hostname       = var.grafana_hostname
    })
  ]
}


resource "helm_release" "loki" {
  atomic     = false
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