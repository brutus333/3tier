resource "google_container_node_pool" "np" {
  name           = "node-pool"
  location       = var.region

  cluster        = google_container_cluster.primary.name
  node_count = var.workers_per_zone
  node_config {
   preemptible = true
   machine_type = var.worker_flavor
   oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
   ]
  }
  timeouts {
    create = "30m"
    update = "20m"
  }
}
resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  node_version       = var.gke_version
  min_master_version = var.gke_version
  initial_node_count = 1
  remove_default_node_pool = true
  location           = var.region
  node_locations     = var.zones
  ip_allocation_policy {

  }
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

