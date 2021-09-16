### Can be moved to TF resources
### SQL Proxy user
#gcloud iam service-accounts list|grep ^"${proxy_user}" || gcloud iam service-accounts create proxy-user --display-name "${proxy_user}"
#MEMBER=$(gcloud iam service-accounts list --filter="NAME=${proxy_user}" --format="value(email)")
#gcloud projects add-iam-policy-binding ${project_id} --member \
#serviceAccount:$MEMBER --role roles/cloudsql.client
#gcloud iam service-accounts keys create credentials.json --iam-account $MEMBER
#
#
#### Pub/Sub user
#gcloud iam service-accounts list|grep ^"${pubsub_user}" || gcloud iam service-accounts create proxy-user --display-name "${pubsub_user}"
#MEMBER=$(gcloud iam service-accounts list --filter="NAME=${pubsub_user}" --format="value(email)")
#gcloud projects add-iam-policy-binding ${project_id} --member \
#serviceAccount:$MEMBER --role roles/pubsub.editor
#gcloud iam service-accounts keys create pubsubcredentials.json --iam-account $MEMBER

export KUBECONFIG=.kubeconfig
gcloud container clusters get-credentials ${cluster_name} --region ${region} --project ${project_id}
#kubectl create secret generic cloudsql-instance-credentials --from-file credentials.json
#kubectl create secret generic pubsub-fluentd-credentials --from-file pubsubcredentials.json
#rm -f credentials.json
#rm -f pubsubcredentials.json
gcloud auth configure-docker eu.gcr.io
