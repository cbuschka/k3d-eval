#!/bin/bash

PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

if [ -z "$(which kubectl 2>/dev/null)" ] && [ ! -f "./kubectl" ]; then
  echo "Installing kubectl..."
  KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
  curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o ./kubectl-${KUBECTL-VERSION}
  rm -f kubectl
  ln -s kubectl-${KUBECTL_VERSION} kubectl
fi
