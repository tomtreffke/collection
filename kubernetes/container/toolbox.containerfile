# Containerfile for an openSUSE-based AKS debug toolbox
FROM opensuse/leap:15.5

# Install base packages
RUN zypper -n refresh && \
    zypper -n install -y \
      curl wget tar gzip unzip ca-certificates \
      python3 python3-pip \
      git jq which \
      bind-utils iproute2 iputils procps \
      gettext sudo && \
    zypper -n clean --all

# Install Azure CLI (via pip for portability)
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    python3 -m pip install --no-cache-dir azure-cli

# Install kubectl (stable)
RUN KUBECTL_URL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    curl -fsSL -o /usr/local/bin/kubectl "${KUBECTL_URL}" && \
    chmod +x /usr/local/bin/kubectl

# Install helm (official install script)
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install kustomize (use upstream install script to avoid JSON/jq quoting issues)
RUN set -eux; \
    curl -fsSL "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" -o /tmp/install_kustomize.sh; \
    bash /tmp/install_kustomize.sh; \
    mv kustomize /usr/local/bin/kustomize; \
    chmod +x /usr/local/bin/kustomize; \
    rm -f /tmp/install_kustomize.sh; \
    sleep 1
# Install kubelogin (Azure AD kubectl plugin)
RUN set -eux; \
    KUBELOGIN_URL=$(curl -fsSL https://api.github.com/repos/Azure/kubelogin/releases/latest | grep browser_download_url | grep -i linux | head -n1 | cut -d '"' -f4); \
    curl -fsSL -o /tmp/kubelogin.tar.gz "${KUBELOGIN_URL}"; \
    tar -xzf /tmp/kubelogin.tar.gz -C /tmp || true; \
    if [ -f /tmp/kubelogin ]; then install -m 0755 /tmp/kubelogin /usr/local/bin/kubelogin; fi; \
    rm -f /tmp/kubelogin* /tmp/kubelogin.tar.gz

# Useful extras: wget, curl already installed; add yq and kubectl plugins if desired
RUN YQ_URL="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64" && \
    curl -fsSL -o /usr/local/bin/yq "${YQ_URL}" && chmod +x /usr/local/bin/yq

# Small housekeeping and default entrypoint
ENV PATH="/usr/local/bin:${PATH}"
ENTRYPOINT ["/bin/bash", "-lc", "trap : TERM INT; while true; do sleep 86400; done"]
