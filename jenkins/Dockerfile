FROM jenkins/jenkins:lts-jdk21

ARG TERRAFORM_VERSION=1.17.2
ARG OPA_VERSION=1.22.4

USER root

RUN apt-get update \
    && apt-get install --yes --no-install-recommends ca-certificates curl git jq python3 unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --silent --show-error \
      "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
      --output "/tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
    && curl --fail --location --silent --show-error \
      "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS" \
      --output /tmp/terraform_SHA256SUMS \
    && cd /tmp \
    && grep "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" terraform_SHA256SUMS | sha256sum --check --strict \
    && unzip "/tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin \
    && rm "/tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" /tmp/terraform_SHA256SUMS

RUN curl --fail --location --silent --show-error \
      "https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64_static" \
      --output /usr/local/bin/opa \
    && curl --fail --location --silent --show-error \
      "https://github.com/open-policy-agent/opa/releases/download/v${OPA_VERSION}/opa_linux_amd64_static.sha256" \
      --output /tmp/opa.sha256 \
    && printf '%s  %s\n' "$(cut -d ' ' -f 1 /tmp/opa.sha256)" /usr/local/bin/opa | sha256sum --check --strict \
    && chmod 0755 /usr/local/bin/opa \
    && rm /tmp/opa.sha256

COPY jenkins/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

USER jenkins
