FROM alpine:3.16.3@sha256:3d426b0bfc361d6e8303f51459f17782b219dece42a1c7fe463b6014b189c86d

RUN apk update
RUN apk add bash curl zip

WORKDIR /tmp

# Terraform
RUN curl -o terraform.zip -L https://releases.hashicorp.com/terraform/1.3.4/terraform_1.3.4_linux_amd64.zip
RUN unzip terraform.zip
RUN mv ./terraform /usr/local/bin/terraform
RUN rm terraform.zip

# Kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Kustomize
RUN curl -Ls "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

# Entrypoint
WORKDIR /mnt
ENTRYPOINT [ "/bin/bash" ]