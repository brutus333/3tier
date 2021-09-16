provider "helm" {
  kubernetes {
    load_config_file = true
    config_path      = ".kubeconfig"
  }
}