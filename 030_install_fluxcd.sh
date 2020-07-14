#!/bin/bash

PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

export KUBECONFIG="$(./k3d get-kubeconfig --name=${CLUSTER_NAME})"

if [ ! -f "./fluxctl" ]; then
  curl -L https://github.com/fluxcd/flux/releases/download/${FLUXCTL_VERSION}/fluxctl_linux_amd64 -o fluxctl-${FLUXCTL_VERSION}
  ln -s fluxctl-${FLUXCTL_VERSION} fluxctl
  chmod 755 fluxctl-${FLUXCTL_VERSION}
fi

./helm repo add fluxcd https://charts.fluxcd.io

kubectl apply -f https://raw.githubusercontent.com/fluxcd/helm-operator/${FLUXCD_OPERATOR_VERSION}/deploy/crds.yaml

# for params see https://hub.helm.sh/charts/fluxcd/helm-operator
helm upgrade -i helm-operator fluxcd/helm-operator --namespace flux --set helm.versions=v2

echo "Creating flux namespace..."
cat - > /tmp/flux-namespace.yml <<EOB
apiVersion: v1
kind: Namespace
metadata:
  name: flux
EOB

kubectl apply -f /tmp/flux-namespace.yml

echo "Fork fluxcd/flux-get-started on GitHub and replace the fluxcd with your GitHub username in release/ghost.yaml"
echo "Add this key to repo:"
./fluxctl identity --k8s-fwd-ns flux
read

helm upgrade -i flux fluxcd/flux --set git.url=git@github.com:cbuschka/flux-get-started --namespace flux 

helm upgrade -i helm-operator fluxcd/helm-operator --set git.ssh.secretName=flux-git-deploy --namespace flux

./fluxctl sync --k8s-fwd-ns flux
