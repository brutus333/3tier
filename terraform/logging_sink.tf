resource "google_logging_project_sink" "db-sink" {
  name = "db-pubsub-instance-sink"

  destination = format("pubsub.googleapis.com/projects/%s/topics/%s", var.project, var.dbloggingtopic)

  filter = "resource.type=\"cloudsql_database\" resource.labels.database_id=\"${var.project}:${google_sql_database_instance.instance.name}\" logName=\"projects/${var.project}/logs/cloudsql.googleapis.com%2Fpostgres.log\""

  # Use a unique writer (creates a unique service account used for writing)
  unique_writer_identity = true
}

resource "google_project_iam_binding" "log-writer" {
  role = "roles/pubsub.editor"

  members = [
    google_logging_project_sink.db-sink.writer_identity,
    "serviceAccount:${google_service_account.log-reader.email}",
  ]
}

resource "google_service_account" "log-reader" {
  account_id   = var.pubsub_user
  display_name = "Fluentd pub/sub reader Account"
}

resource "google_service_account_key" "log-reader-key" {
  service_account_id = google_service_account.log-reader.name
}

resource "kubernetes_secret" "log-reader-credentials" {
  metadata {
    name = "pubsub-fluentd-credentials"
  }
  data = {
    "credentials.json" = base64decode(google_service_account_key.log-reader-key.private_key)
  }
  depends_on = [ google_container_node_pool.np, google_container_cluster.primary, null_resource.run-gcloud ]
}

resource "google_pubsub_topic" "dblogging" {
  name = var.dbloggingtopic

  message_storage_policy {
    allowed_persistence_regions = [
      var.region,
    ]
  }
}

resource "google_pubsub_subscription" "monitoring" {
  name  = "db-monitoring"
  topic = google_pubsub_topic.dblogging.name

  labels = {
    sink = "db"
  }

  # 10 minutes
  message_retention_duration = "600s"
  retain_acked_messages      = false

  ack_deadline_seconds = 20

  expiration_policy {
    ttl = "86400.5s"
  }
}