#!/bin/bash

set -e
 
PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

echo "Creating cluster ${CLUSTER_NAME}..."
./k3d cluster create ${CLUSTER_NAME} --api-port 6443 --port 0.0.0.0:80:80@server[0] --port 0.0.0.0:443:443@server[0] --servers ${SERVER_COUNT}

echo "Starting cluster..."
./k3d cluster start ${CLUSTER_NAME}

./011_show_status.sh
