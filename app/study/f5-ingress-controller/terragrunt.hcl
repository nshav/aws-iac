include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/f5-ingress-controller"
}

dependency "cert_issuer" {
  config_path = "../cert-manager"
  skip_outputs = true
}
