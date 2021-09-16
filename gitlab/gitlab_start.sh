#!/usr/bin/env bash
 docker run --detach \
  --hostname mygitlab.local.com \
  --env GITLAB_OMNIBUS_CONFIG="external_url 'http://mygitlab.local.com/'; gitlab_rails['lfs_enabled'] = true; gitlab_rails['initial_root_password'] = 'password'; registry_external_url 'https://mygitlab.local.com:5050'" \
  --publish 443:443 --publish 80:80 --publish 22:22 --publish 5050:5050 \
  --name gitlab \
  --restart always \
  --volume gitlab_config:/etc/gitlab \
  --volume gitlab_logs:/var/log/gitlab \
  --volume gitlab_data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
docker exec $(docker ps -ql) bash -c '
cat > caconfig.conf <<MARK
[ ca ]
default_ca = local_ca
[ local_ca ]
dir = .
certificate = $dir/cacert.pem
database = $dir/index.txt
new_certs_dir = $dir/signedcerts
private_key = $dir/private/cakey.pem
serial = $dir/serial
default_crl_days = 365
default_days = 1825
default_md = sha256
policy = local_ca_policy
x509_extensions = local_ca_extensions
copy_extensions = copy
[ local_ca_policy ]
commonName = supplied
stateOrProvinceName = optional
countryName = supplied
emailAddress = optional
organizationName = supplied
organizationalUnitName = supplied
[ local_ca_extensions ]
basicConstraints = CA:false
[ req ]
default_bits = 2048
default_keyfile = cakey.pem
default_md = sha256
prompt = no
distinguished_name = root_ca_distinguished_name
x509_extensions = root_ca_extensions
[ root_ca_distinguished_name ]
commonName = ca.local.com
countryName = RO
emailAddress = admin@local.com
organizationName = Smart
organizationalUnitName =IT
[ root_ca_extensions ]
basicConstraints = CA:true
MARK
cat > openssl.conf <<MARK
[req]
x509_extensions = x509_ext
distinguished_name = dn

[dn]
CN = mygitlab.local.com

[x509_ext]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = mygitlab.local.com
IP.1 = 127.0.0.1
MARK
openssl req -config caconfig.conf -nodes -x509 -newkey rsa:2048 -out cacert.pem -outform PEM -days 1825
openssl req -config openssl.conf -nodes -newkey rsa:2048 -keyout tempkey.pem -keyform PEM -out cert_csr.csr
openssl rsa -in tempkey.pem -out server_key.pem
openssl ca -config caconfig.conf -batch -in cert_csr.csr -out server_crt.pem

openssl req -new -x509 -sha256 -newkey rsa:2048 -nodes -keyout key.pem -out cert.pem -days 365 -subj "/C=RO/L=BUcharest/OU=Smart/CN=mygitlab.local.com" -config openssl.conf
mkdir /etc/gitlab/ssl
cp cert.pem /etc/gitlab/ssl/mygitlab.local.com.crt
cp key.pem /etc/gitlab/ssl/mygitlab.local.com.key
'
docker cp $(docker ps -ql):/etc/gitlab/ssl/mygitlab.local.com.crt ca.crt
docker cp ca.crt gitlab-runner:/etc/gitlab-runner/certs/ca.crt

registration_token=p9EMaJi9x3mFncmygsrX
docker exec -it gitlab-runner1 \
  gitlab-runner register \
    --non-interactive \
    --registration-token ${registration_token} \
    --locked=false \
    --description docker-stable \
    --url http://mygitlab.local.com \
    --executor docker \
    --docker-image docker:stable \
    --docker-network-mode host \
    --docker-dns 127.0.0.11 \
    --docker-host tcp://docker:2375 \
    --tag-list docker


    --docker-volumes '/certs/client:/certs/client' \
    --docker-cert-path '/etc/gitlab/ssl/'

        --docker-tlsverify \
    --docker-cert-path /certs/client \
    --tls-cert-file /certs/client/cert.pem \
    --tls-ca-file /certs/client/ca.pem \
    --tls-key-file /certs/client/key.pem

gitlab-runner register --non-interactive --registration-token ${registration_token} --locked=false --description docker --tag-list docker --url http://mygitlab.local.com --executor docker --docker-image docker:stable

gitlab-runner exec docker build --executor docker \
    --docker-tlsverify \
    --docker-image docker:stable \
    --docker-network-mode host \
    --docker-dns 127.0.0.11 \
    --docker-host tcp://docker:2376 \
    --docker-cert-path /certs/client



docker exec -it gitlab-runner1 \
  gitlab-runner register \
    --non-interactive \
    --registration-token ${registration_token} \
    --locked=false \
    --description docker-stable \
    --url http://mygitlab.local.com \
    --executor docker \
    --docker-image docker:stable \
    --docker-