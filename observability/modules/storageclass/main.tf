resource "kubernetes_manifest" "storageclass" {
  manifest = yamldecode(file("./storageclass.yaml"))
}