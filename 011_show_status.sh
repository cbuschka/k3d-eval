#!/bin/bash
  
PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

echo "k3d version: ${K3D_VERSION}"

echo "All k3d clusters..."
./k3d list

echo "k3d docker containers..."
docker ps | grep k3d

export KUBECONFIG="$(./k3d get-kubeconfig --name=${CLUSTER_NAME})"
kubectl cluster-info 

echo "Nodes of cluster ${CLUSTER_NAME}..."
kubectl get nodes

echo "Namespaces of cluster ${CLUSTER_NAME}..."
kubectl get namespaces

echo "Pods in cluster ${CLUSTER_NAME}..."
kubectl get pods --all-namespaces

echo "Ingresses of cluster ${CLUSTER_NAME}..."
kubectl get ingresses --all-namespaces
