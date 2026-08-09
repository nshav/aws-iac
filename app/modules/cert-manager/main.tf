resource "helm_release" "cert_manager" {
  atomic     = true
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = var.cm_name
  create_namespace = true

  values = [
    "${file("values.yaml")}"
  ]
}
