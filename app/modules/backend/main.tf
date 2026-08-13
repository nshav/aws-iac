resource "kubernetes_manifest" "httpbin" {
  manifest = yamldecode(file("./httpbin.yaml"))
}

resource "kubernetes_manifest" "service_httpbin" {
  manifest = yamldecode(file("./service_httpbin.yaml"))
}

resource "kubernetes_manifest" "ingress_f5" {
    manifest = yamldecode(templatefile("${path.module}/ingress_f5.yaml", {
      hostname = var.httpbin_hostname
      wallarm_mode = var.wallarm_mode
    }))
  }
