#!/bin/bash

set -e
 
PROJECT_DIR=$(cd `dirname $0`/.. && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

echo "Creating cluster ${CLUSTER_NAME}..."
./k3d cluster create ${CLUSTER_NAME} --k3s-arg '--disable=traefik@server:*' --api-port 127.0.0.1:6443 --port 0.0.0.0:80:80@loadbalancer --port 0.0.0.0:443:443@loadbalancer --servers ${SERVER_COUNT} --agents ${AGENT_COUNT}

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml
