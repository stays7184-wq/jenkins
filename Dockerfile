FROM jenkins/inbound-agent:latest-jdk21

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        python3 \
        python3-pip \
        python3-venv && \
    rm -rf /var/lib/apt/lists/*

# kubectl, so pipelines can talk to the cluster
ARG KUBECTL_VERSION=v1.35.1
RUN curl -fsSL --retry 5 --retry-delay 3 -o /usr/local/bin/kubectl \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

RUN python3 --version && git --version && kubectl version --client

USER jenkins
