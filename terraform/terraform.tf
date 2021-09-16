terraform {
  backend "gcs" {
    bucket  = "node-3tier-tf-state-prod"
    prefix  = "terraform/state"
  }
}