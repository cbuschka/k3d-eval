#!/bin/bash
  
PROJECT_DIR=$(cd `dirname $0` && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

export KUBECONFIG="$(./k3d get-kubeconfig --name=${CLUSTER_NAME})"

echo "Creating dev namespace..."
cat - > /tmp/dev-namespace.yml <<EOB
apiVersion: v1
kind: Namespace
metadata:
  name: dev
EOB

kubectl apply -f /tmp/dev-namespace.yml

echo "Creating deployment..."
cat - > /tmp/hello-deployment.yml <<EOB
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: dev
  name: hello-deployment
  labels:
    app: hello
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello
  template:
    metadata:
      namespace: dev 
      labels:
        app: hello
    spec:
      containers:
      - name: hello
        image: docker.io/cbuschka/myhello:3.0
        ports:
        - containerPort: 8080
EOB
kubectl apply -f /tmp/hello-deployment.yml

echo "Creating service..."
cat - > /tmp/hello-service.yml <<EOB
apiVersion: v1
kind: Service
metadata:
  namespace: dev 
  name: hello-service
spec:
  selector:
    app: hello
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 8080
  type: ClusterIP
EOB

kubectl apply -f /tmp/hello-service.yml

echo "Creating ingress..."
cat - > /tmp/hello-ingress.yml <<EOB
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-ingress
  namespace: dev
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - http:
      paths:
      - path: /hello
        backend:
          serviceName: hello-service
          servicePort: 80
EOB

kubectl apply -f /tmp/hello-ingress.yml

echo "Now you can access via proxy (remember start 'kubectl proxy' first)...

http://localhost:8001/api/v1/namespaces/dev/services/http:hello-service:80/proxy/#

or via ingress

http://localhost/hello
"
