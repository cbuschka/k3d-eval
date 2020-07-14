# k3d evaluation

## requirements
* curl
* docker
* bash
* linux

## steps
* 000_install_k3d.sh - install k3d
* 010_setup_cluster.sh - setup a cluster
* 011_install_dashboard.sh - install the k8s dashboard (optional)
* 020_create_dev.sh - setup a dev namespace and deploy an hello world app with ingress
* 999_destroy_all.sh - destroy the cluser
* configrc - config for cluster name and k3d version
* get_token.sh - script to request the login token for dashboard login from cluster
