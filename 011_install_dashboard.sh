#!/bin/bash

PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

export KUBECONFIG="$(./k3d get-kubeconfig --name=${CLUSTER_NAME})"

echo "Installing dashboard..."
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubernetes/dashboard/releases/latest -o /dev/null | sed -e 's|.*/||')

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml

echo "Creating admin user 'admin' in namespace kubernetes-dashboard..."
cat - > /tmp/dashboard.admin-user.yml <<EOB
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOB

kubectl apply -f /tmp/dashboard.admin-user.yml

echo "Granting cluster-admin role to user admin..."
cat - > /tmp/dashboard.admin-user-role.yml <<EOB
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOB

kubectl apply -f /tmp/dashboard.admin-user-role.yml

echo "
Get token via ./get_token.sh, 
start proxy with 'kubectl proxy' 
and use browser to login to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
" 
