data "helm_repository" "loki" {
  name = "loki"
  url  = "https://grafana.github.io/loki/charts"
}

resource "helm_release" "loki-stack" {
  name = "loki-stack"
  depends_on = [ null_resource.run-gcloud, google_container_node_pool.np, google_container_cluster.primary ]
  repository = data.helm_repository.loki.metadata[0].name
  chart = "loki-stack"
  force_update = true
  cleanup_on_fail = true
  recreate_pods = true
  atomic = true
  set {
    name = "fluent-bit.enabled"
    value = true
  }
  set {
    name = "grafana.enabled"
    value = true
  }
  set {
    name = "prometheus.enabled"
    value = true
  }
  values = [ var.grafana_config, var.prometheus_config, var.promtail_config ]
}


resource "helm_release" "fluentd-pubsub" {
  name = "fluentd-pubsub"
  depends_on = [ null_resource.run-gcloud, google_container_node_pool.np, google_container_cluster.primary, helm_release.loki-stack, kubernetes_secret.log-reader-credentials ]
    chart      = "${path.module}/../fluentd"
  force_update = true
  cleanup_on_fail = true
  recreate_pods = true
  atomic = true
  set {
    name = "loki.url"
    value = "http://loki-stack:3100"
  }
  set {
    name = "gcloud.project"
    value = var.project
  }
  set {
    name = "gcloud.key"
    value = "/etc/gcloud/credentials.json"
  }
  set {
    name = "gcloud.pubsub.topic"
    value = google_pubsub_topic.dblogging.name
  }
  set {
    name = "gcloud.pubsub.subscription"
    value = google_pubsub_subscription.monitoring.name
  }
}