data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "node-3tier" {
  depends_on = [ null_resource.run-gcloud, google_container_node_pool.np, google_container_cluster.primary, kubernetes_secret.sql-proxy-credentials ]
  name       = "3tier"
  chart      = "${path.module}/../helm"
  force_update = true
  cleanup_on_fail = true
  recreate_pods = true
  atomic = true
  set {
    name = "postgresqlUrl"
    value = format("postgres://%s:%s@127.0.0.1:5432/%s", var.dbuser, random_string.password.result, "pgsql-database" )
  }
  set {
    name = "instanceConnectionName"
    value = google_sql_database_instance.instance.connection_name
  }
  set {
    name = "image.api.tag"
    value = var.image_api_tag
  }
  set {
    name = "image.web.tag"
    value = var.image_web_tag
  }
  set {
    name = "replicaCount"
    value = 6
  }
}
