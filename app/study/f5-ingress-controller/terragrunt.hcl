include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/f5-ingress-controller"
}

inputs = {
  wallarm_api_host = get_env("WALLARM_HOST")
  wallarm_api_token = get_env("WALLARM_TOKEN")
}

dependency "cert_issuer" {
  config_path = "../cert-manager"
  skip_outputs = true
}
