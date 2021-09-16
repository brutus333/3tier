data "google_compute_network" "default" {
  name = "default"
  project = var.project
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default.self_link
}

resource "google_service_networking_connection" "serviceconnection" {
  network                 = data.google_compute_network.default.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

resource "google_compute_global_address" "external-web" {
  name        = "public-ip-alloc"
  address_type = "EXTERNAL"
}