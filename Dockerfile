FROM registry.access.redhat.com/ubi8/ubi:latest
ARG GOLANG_VERSION="1.18.6"
ARG ARCH_X86="x86_64"
ARG ARCH_AMD="amd64"

# Image identification
LABEL name="containerized-argocd-e2e" \
      version="0.1.0" \
      summary="ArgoCD remote E2E client" \
      description="A UBI-8 image with all the tools needed to run ArgoCD remote E2E tests"

# Install dependencies
RUN sudo dnf install -y \
    curl \
    gcc \
    git \
    golang-sigs-k8s-kustomize \
    make \
    perl-Digest-SHA \
    tar \
    unzip

# Install Go 1.18
RUN curl -sSL -o /tmp/golang.tar.gz \
    "https://go.dev/dl/go${GOLANG_VERSION}.linux-${ARCH_AMD}.tar.gz" &&\
    rm -rf /usr/local/go &&\
    tar -xzf /tmp/golang.tar.gz -C /usr/local
#RUN export PATH=$PATH:/usr/local/go/bin

# Install OC and Kubectl
RUN curl -sSL -o /tmp/oc.tar.gz \
    "https://mirror.openshift.com/pub/openshift-v4/${ARCH_X86}/clients/ocp/latest/openshift-client-linux.tar.gz" &&\
    tar -xzf /tmp/oc.tar.gz -C /usr/local/bin oc kubectl

# Install ArgoCD CLI
RUN curl -sSL -o /usr/local/bin/argocd \
    "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-${ARCH_AMD}" &&\
    chmod +x /usr/local/bin/argocd

# Entrypoint
ENTRYPOINT [ "git", \
             "clone", \
             "https://github.com/argoproj/argo-cd.git", \
             "/tmp/argo-cd"
]

