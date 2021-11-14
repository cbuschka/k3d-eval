#!/bin/bash

set -e

PROJECT_DIR=$(cd `dirname $0`/.. && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

./k3d cluster delete ${CLUSTER_NAME}
