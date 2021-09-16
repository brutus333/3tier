data "template_file" "gcloud" {
  template = file("${path.module}/templates/gcloud.tpl")
  vars = {
    proxy_user = "${var.proxy_user}"
    pubsub_user = "${var.pubsub_user}"
    project_id = "${var.project}"
    cluster_name = "${var.cluster_name}"
    region = "${var.region}"
  }
}

resource "local_file" "gcloud-shell" {
  filename = "${path.module}/gcloud.sh"
  content = data.template_file.gcloud.rendered
}

resource "null_resource" "run-gcloud" {
  depends_on = [ local_file.gcloud-shell, google_container_cluster.primary ]
  provisioner "local-exec" {
    command = "bash ${path.module}/gcloud.sh"
  }
}
