#!/bin/bash

set -e
 
PROJECT_DIR=$(cd `dirname $0`/.. && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

./k3d kubeconfig merge ${CLUSTER_NAME}

echo "Creating dev namespace..."
cat - > /tmp/dev-namespace.yml <<EOB
apiVersion: v1
kind: Namespace
metadata:
  name: dev
EOB

kubectl apply -f /tmp/dev-namespace.yml
