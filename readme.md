# k3d evaluation session

## installation

### download k3d
```shell
K3D_VERSION=1.7.0

curl -L https://github.com/rancher/k3d/releases/download/${K3D_VERSION}/k3d-linux-amd64 -o k3d

chmod 755 k3d
```

### create a local cluster
```shell
./k3d create --api-port 6443 --publish 0.0.0.0:80:80 --publish 0.0.0.0:443:443 --name=testcluster --workers 2

./k3d start --name=testcluster

./k3d list
```

## customize

### switch to kubectl
```shell
export KUBECONFIG="$(./k3d get-kubeconfig --name='testcluster')"
kubectl cluster-info 

kubectl get nodes

kubectl get pods --all-namespaces
```

### install kube-dashboard
(see https://rancher.com/docs/k3s/latest/en/installation/kube-dashboard/)
```
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/kubernetes/dashboard/releases/latest -o /dev/null | sed -e 's|.*/||')
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml

cat - > dashboard.admin-user.yml <<EOB
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOB

cat - > dashboard.admin-user-role.yml <<EOB
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
kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
```

## use/ deploy app

### get admin token
```
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token | perl -pe 's#^.*token\:\s*([^\s\n]+).*$#$1#g'
```

### start proxy (tunnel requests to localhost:8001 to k8s api)
```
kubectl proxy
```

### access dashboard via browser
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

## install hello app via deployment
```
cat - > dev-namespace.yml <<EOB
apiVersion: v1
kind: Namespace
metadata:
  name: dev
EOB

cat - > hello-deployment.yml <<EOB
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

cat - > hello-service.yml <<EOB
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

kubectl apply -f dev-namespace.yml -f hello-service.yml -f hello-deployment.yml
```

### configure ingress (https://docs.traefik.io/v1.7/configuration/backends/kubernetes/)
```
cat - > hello-ingress.yml <<EOB
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

kubectl apply -f hello-ingress.yml
```

## access service via proxy
http://localhost:8001/api/v1/namespaces/dev/services/http:hello-service:80/proxy/#

or via ingress

http://localhost/hello

## clean up
```
./k3d delete cluster --name=testcluster
```
