#!/bin/bash

PROJECT_DIR=$(cd `dirname $0`/.. && pwd -P)

. ${PROJECT_DIR}/configrc

${PROJECT_DIR}/k3d kubeconfig merge ${CLUSTER_NAME}

kubectl get services --all-namespaces
