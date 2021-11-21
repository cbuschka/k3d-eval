#!/bin/bash

set -e
 
PROJECT_DIR=$(cd `dirname $0`/.. && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

echo "Creating cluster ${CLUSTER_NAME}..."
./k3d cluster create --config ${CLUSTER_NAME}-config.yml

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml
