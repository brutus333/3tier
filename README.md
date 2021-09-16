# Sample 3tier app
This repo contains code for a Node.js multi-tier application.

The application overview is as follows

```
web <=> api <=> db
```

The folders `web` and `api` respectively describe how to install and run each app.


## Requirements

* With a google cloud account create or configure the following:
  - a project
  - a service account with the following roles:
    + Browser
    + Cloud SQL Admin
    + Compute Instance Admin (beta)
    + Kubernetes Engine Admin
    + Service Account User
    + Compute Network Admin
    + Security Admin
    + Logging Admin
    + Pub/Sub Admin
    + Storage Object Creator
    + Storage Object Viewer
  Save the key in JSON credentials form.
    
  - enable the following APIs:
    + Stackdriver API
    + Compute Engine API	
    + Cloud Monitoring API	
    + Cloud Logging API	
    + Cloud SQL Admin API	
    + Kubernetes Engine API
    + Cloud Resource Manager API
    + Service Networking API
    + Cloud Pub/Sub API
   

  - create a storage bucket for TF state with name: 
    node-3tier-tf-state-prod in the region europe-west1 (for change of the region please check the terraform variable section)
  - give the service account created before access to this storage bucket

## Installation & configuration

Solution was tested on a Windows 10 workstation with the following software installed and configured:

1. Docker for desktop 2.2.0.5
2. Gitlab Community Edition 12.9.2
3. Terraform v0.12.24
4. Helm 3.2.0
5. Google Cloud SDK 289.0.0
6. Kubectl 1.15.0
7. Gitlab runner 12.10.1
8. Git for Windows 2.17.1 with Git Bash
9. Python for Windows 2.7.14

You'll have to configure gcloud according to official documentation. You may check the environment using `gcloud info` command.

After importing the repository in the Gitlab instance configure one file variable in the project with the following name: `GOOGLE_APPLICATION_CREDENTIALS` and with the value the content of service account key credentials file gathered while fulfilling the requirements.

Go to Settings->CI/CD->Runners->Specific Runners section in gitlab and copy the project registration token

Ensure that the following binaries are present in git bash path: terraform, gcloud, python, kubectl, helm, git, docker, gitlab-runner

Open a new git bash window and type the following, replacing `<registration token>` with the value copied before and `<address of gitlab instance>` with the hostname of the Gitlab instance:

```
mkdir /c/gitlab-runner
cd /c/gitlab-runner
export registration_token=<registration token>
gitlab-runner register --non-interactive --registration-token ${registration_token} \
--locked=false --description shell-exec --url http://mygitlab.local.com \
--executor shell --shell bash --tag-list shell
gitlab-runner register --non-interactive --registration-token ${registration_token} \
--locked=false --description docker --tag-list docker --url http://<address of gitlab instance> \
--executor docker --docker-image docker:stable --docker-pull-policy if-not-present
```
Edit the config.toml file created by gitlab-runner and add the following lines in `[[runners]]` section corresponding to `shell-exec` runner:

```
  builds_dir="/c/gitlab-runner/builds/"
  cache_dir="/c/gitlab-runner/cache/"
```

Run the following command:
```
gitlab-runner --debug run
```

and check for errors.

Meanwhile, go back to Settings->CI/CD->Runners and enable the runners for the project, if needed.

