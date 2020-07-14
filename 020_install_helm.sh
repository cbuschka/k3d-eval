#!/bin/bash

PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

if [ ! -f "helm-${HELM_VERSION}" ]; then
  curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -o /tmp/helm.tgz
  tar xvfz /tmp/helm.tgz --strip-components=1 linux-amd64/helm linux-amd64/tiller
  mv helm helm-${HELM_VERSION} && ln -s helm-${HELM_VERSION} helm
  mv tiller tiller-${HELM_VERSION} && ln -s tiller-${HELM_VERSION} tiller
fi

export KUBECONFIG="$(./k3d get-kubeconfig --name=${CLUSTER_NAME})"

# see https://v2.helm.sh/docs/using_helm/#role-based-access-control
cat - >/tmp/tiller-account.yml <<EOB
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
EOB

kubectl apply -f /tmp/tiller-account.yml

./helm init --wait --upgrade --service-account tiller --history-max 200
