FROM ruby:2.6.6
MAINTAINER virgil.chereches@gmail.com
USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

#Install fluent-plugin-grafana-loki from source
#https://github.com/grafana/loki/issues/719
RUN rm -rf /tmp/loki \
    && git clone --depth 1 https://github.com/grafana/loki.git /tmp/loki \
    && cd /tmp/loki/fluentd/fluent-plugin-grafana-loki \
    && sed -i "s|^  spec.files.*|  spec.files = Dir.glob('{bin,lib}/**/*')|" fluent-plugin-grafana-loki.gemspec \
    && gem build fluent-plugin-grafana-loki.gemspec \
    && gem install fluent-plugin-grafana-loki-*.gem \
    && cd /tmp \
    && rm -rf /tmp/loki

RUN gem install fluent-plugin-gcloud-pubsub-custom -v 1.3.2

ENTRYPOINT ["fluentd", "-v", "-c", "/etc/fluent/fluent.conf"]

