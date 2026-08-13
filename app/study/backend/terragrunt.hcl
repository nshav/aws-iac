include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/backend"
}

inputs = {
  httpbin_hostname = get_env("HTTPBIN_HOSTNAME")
  wallarm_mode = get_env("WALLARM_MODE")
} 