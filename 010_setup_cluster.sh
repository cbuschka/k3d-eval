#!/bin/bash
  
PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

echo "Creating cluster ${CLUSTER_NAME}..."
./k3d create --api-port 6443 --publish 0.0.0.0:80:80 --publish 0.0.0.0:443:443 --name=${CLUSTER_NAME} --workers 2

echo "Starting cluster..."
./k3d start --name=${CLUSTER_NAME}

./k3d list

./012_show_status.sh
