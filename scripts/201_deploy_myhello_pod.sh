#!/bin/bash

set -e
 
PROJECT_DIR=$(cd `dirname $0`/.. && pwd)
cd ${PROJECT_DIR}

source ${PROJECT_DIR}/configrc

./k3d kubeconfig merge ${CLUSTER_NAME}

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
  replicas: 4
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
        image: docker.io/cbuschka/myhello:5.0
        env:
          - name: MESSAGE
            value: "Moin!"
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
apiVersion: networking.k8s.io/v1
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
        pathType: Prefix
        backend:
          service:
            name: hello-service
            port:
              number: 80
EOB

kubectl apply -f /tmp/hello-ingress.yml

echo "Now you can access via proxy (remember start 'kubectl proxy' first)...

http://localhost:8001/api/v1/namespaces/dev/services/http:hello-service:80/proxy/#

or via ingress

http://localhost/hello
"
