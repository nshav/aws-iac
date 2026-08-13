resource "kubernetes_manifest" "cluster_issuer" {
  manifest = yamldecode(file("./cluster_issuer.yaml"))
}

resource "kubernetes_manifest" "ingress_f5_namespace" {
  manifest = yamldecode(file("./ingress-namespace.yaml"))
}

resource "helm_release" "f5_ingress" {
  atomic     = true
  name       = var.wallarm_ic_name
  repository = "https://charts.wallarm.com"
  chart      = "wallarm-ingress"
  namespace  = "f5-ingress"
  version    = var.wallarm_ic_version

  values = [
    templatefile("${path.module}/values.yaml", {
      wallarm_host  = var.wallarm_api_host
      wallarm_token = var.wallarm_api_token
    })

  ]
}
