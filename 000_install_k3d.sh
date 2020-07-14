#!/bin/bash

PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

if [ ! -f k3d-${K3D_VERSION} ]; then
  echo "Downloading k3d ${K3D_VERSION}..."
  curl -L https://github.com/rancher/k3d/releases/download/${K3D_VERSION}/k3d-linux-amd64 -o k3d-${K3D_VERSION}
fi

rm -f k3d
ln -s k3d-${K3D_VERSION} k3d
chmod 755 k3d-${K3D_VERSION}
