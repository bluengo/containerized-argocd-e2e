FROM registry.access.redhat.com/ubi8/ubi:latest

ARG GOLANG_VERSION="1.18.6"
ARG HELM_VER="v3.10.0"
ARG OS_TYPE="linux"
ARG ARCH_X86="x86_64"
ARG ARCH_AMD="amd64"

# Image identification
LABEL name="containerized-argocd-e2e" \
      version="0.1.0" \
      summary="ArgoCD remote E2E client" \
      description="A UBI-8 image with all the tools needed to run ArgoCD remote E2E tests"

# Install dependencies
RUN dnf install -y \
    curl \
    gcc \
    git \
    make \
    perl-Digest-SHA \
    tar \
    unzip

# Install Go ($GOLANG_VERSION)
RUN curl -SL -o /tmp/golang.tar.gz \
    "https://go.dev/dl/go${GOLANG_VERSION}.${OS_TYPE}-${ARCH_AMD}.tar.gz" &&\
    rm -rf /usr/local/go &&\
    tar -xzf /tmp/golang.tar.gz -C /usr/local

RUN echo 'export PATH=${PATH}:/usr/local/go/bin' >> /etc/bashrc

# Install OC and Kubectl (latest)
RUN curl -SL -o /tmp/oc.tar.gz \
    "https://mirror.openshift.com/pub/openshift-v4/${ARCH_X86}/clients/ocp/latest/openshift-client-${OS_TYPE}.tar.gz" &&\
    tar -xzf /tmp/oc.tar.gz -C /usr/local/bin oc kubectl

# Install Kustomize (latest)
RUN curl -SL -o /tmp/kustomize.tar.gz \
    $(curl -sSL \
        "https://api.github.com/repos/kubernetes-sigs/kustomize/releases" \
        | egrep "browser_download.*${OS_TYPE}.*${ARCH_AMD}" \
        | egrep -o 'https://[^ "]+' \
        | head -1 \
    ) &&\
    tar -xzf /tmp/kustomize.tar.gz -C /usr/local/bin

# Install Helm ($HELM_VER)
RUN curl -SL -o /tmp/helm.tar.gz \
    "https://get.helm.sh/helm-${HELM_VER}-${OS_TYPE}-${ARCH_AMD}.tar.gz" &&\
    tar -xzf /tmp/helm.tar.gz -C /tmp &&\
    mv "/tmp/${OS_TYPE}-${ARCH_AMD}/helm" /usr/local/bin

# Install ArgoCD CLI (latest)
RUN curl -SL -o /usr/local/bin/argocd \
    "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-${OS_TYPE}-${ARCH_AMD}" &&\
    chmod +x /usr/local/bin/argocd

# Clone ArgoCD repo
RUN git clone \
    "https://github.com/argoproj/argo-cd.git" \
    "/tmp/argo-cd"

# Entrypoint
CMD [ "git", \
      "-C", \
      "/tmp/argo-cd", \
      "pull", \
      "--rebase" \
]
