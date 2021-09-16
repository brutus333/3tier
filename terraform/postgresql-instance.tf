resource "google_sql_database" "database" {
  name     = "pgsql-database"
  instance = google_sql_database_instance.instance.name
  project = var.project
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  name   = "pgsql-database-instance-${random_id.db_name_suffix.hex}"
  region = var.region
  database_version = "POSTGRES_11"
  depends_on = [google_service_networking_connection.serviceconnection]
  settings {
    tier = var.db_flavor
    disk_size = var.database_size_GB
    availability_type = "REGIONAL"
    backup_configuration {
      enabled = true
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.default.self_link
    }
  }
}

resource "random_string" "password" {
  length = 16
  min_lower = 2
  min_upper = 2
  min_special = 2
  min_numeric = 2
  special = true
  override_special = "/#&%$"
  keepers = {
    instance_id = google_sql_database_instance.instance.id
  }
}

resource "google_sql_user" "users" {
  name     = var.dbuser
  instance = google_sql_database_instance.instance.name
  password = random_string.password.result
}

resource "google_project_iam_binding" "sqlproxy-binding" {
  role = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.sqlproxy.email}",
  ]
}

resource "google_service_account" "sqlproxy" {
  account_id   = var.proxy_user
  display_name = "Sqlproxy service account"
}

resource "google_service_account_key" "sqlproxy-key" {
  service_account_id = google_service_account.sqlproxy.name
}

resource "kubernetes_secret" "sql-proxy-credentials" {
  metadata {
    name = "cloudsql-instance-credentials"
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.sqlproxy-key.private_key)
  }
  depends_on = [ google_container_node_pool.np, google_container_cluster.primary, null_resource.run-gcloud ]
}