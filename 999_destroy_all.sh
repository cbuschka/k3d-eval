#!/bin/bash

PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

./k3d delete cluster --name=${CLUSTER_NAME}
