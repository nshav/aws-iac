include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/observability"
}

inputs = {
  cluster_name = get_env("CLUSTER_NAME")
  aws_region = get_env("AWS_DEFAULT_REGION")
  grafana_admin_password = get_env("GRAFANA_ADMIN_PASSWORD")
  grafana_hostname = get_env("GRAFANA_HOSTNAME")
}

dependency "storageclass" {
  config_path = "../storageclass"
  skip_outputs = true
}
