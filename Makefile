TOP_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all:	prepare create status deploy logs

prepare:
	$(TOP_DIR)/scripts/000_install_k3d.sh && \
	$(TOP_DIR)/scripts/001_install_kubectl.sh

create:
	$(TOP_DIR)/scripts/100_setup_cluster.sh && \
	$(TOP_DIR)/scripts/101_show_status.sh && \
	$(TOP_DIR)/scripts/102_install_dashboard.sh

status:
	@echo "Docker containers..." && \
	docker ps && \
	echo "Cluster info..." && \
	$(TOP_DIR)/scripts/101_show_status.sh

logs:
	$(TOP_DIR)/scripts/tail-myhello-pod.sh

deploy:
	$(TOP_DIR)/scripts/200_create_dev_ns.sh && \
	$(TOP_DIR)/scripts/201_deploy_myhello_pod.sh

proxy:
	$(TOP_DIR)/scripts/start-proxy.sh

get-dashboard-token:
	$(TOP_DIR)/scripts/get-dashboard-token.sh

destroy:
	$(TOP_DIR)/scripts/destroy-cluster.sh
