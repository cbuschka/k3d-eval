#!/bin/bash
  
PROJECT_DIR=$(cd `dirname $0/..` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

./k3d kubeconfig merge ${CLUSTER_NAME}

echo "Username: admin"
echo "Token: $(kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token | perl -pe 's#^.*token\:\s*([^\s\n]+).*$#$1#g')"
