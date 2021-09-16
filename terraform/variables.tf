variable "project" {
  type = string
  default = "node-3tier"
}
variable "worker_flavor" {
  type = string
  default = "e2-medium"
}
variable "db_flavor" {
  type = string
  default = "db-f1-micro"
}
variable "workers_per_zone" {
  type = number
  default = 1
}
variable "gke_version" {
  type = string
  default = "1.15.11-gke.9"
}
variable "region" {
  type = string
  default = "europe-west1"
}
variable "zones" {
  type = list(string)
  default = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
}
variable "database_size_GB" {
  type = number
  default = 10
}
variable "dbuser" {
  type = string
  default = "node"
}
variable "dbloggingtopic" {
  type = string
  default = "dbtopic"
}
variable "cluster_name" {
  type = string
  default = "production"
}
variable "proxy_user" {
  type = string
  default = "sql-proxy-user"
}
variable "pubsub_user" {
  type = string
  default = "fluentd"
}
variable "image_api_tag" {
  type = string
  default = "latest"
}
variable "image_web_tag" {
  type = string
  default = "latest"
}
variable "promtail_config" {
  type = string
  default = <<EOF
promtail:
  pipelineStages:
    - docker: {}
    - regex:
        expression: |
          ^.*GET .*(?P<serviceTime>\d+[.]\d+) ms .*$
    - metrics:
        service-time:
          type: Gauge
          description: "request service time"
          source: serviceTime
          config:
            action: set
EOF
}
variable "grafana_config" {
  type = string
  default = <<EOF
grafana:
  plugins:
    - grafana-kubernetes-app
    - devopsprodigy-kubegraf-app
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/default
  dashboards:
    default:
      postgresql-dashboard:
        gnetId: 6742
        revision: 1
        datasource: Prometheus
      postgresql-overview:
        gnetId: 455
        revision: 2
        datasource: Prometheus
      kubernetes-dashboard:
        gnetId: 6417
        revision: 1
        datasource: Prometheus
      node-exporter-dashboard:
        gnetId: 1860
        revision: 18
        datasource: Prometheus
EOF
}
variable "prometheus_config" {
  type = string
  default = <<EOF
prometheus:
  extraScrapeConfigs: |
    - job_name: 'prometheus-postgres-exporter'
      static_configs:
        - targets:
          - pg-exporter:9187
    - job_name: 'promtail-metrics'
      static_configs:
        - targets:
          - loki-stack:3101
EOF
}