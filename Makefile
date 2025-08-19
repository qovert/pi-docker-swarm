# Makefile for Raspberry Pi 5 Cluster Management

.PHONY: help deploy deploy-dry check-connectivity clean-backups deploy-all deploy-infrastructure deploy-platform deploy-apps setup-docker deploy-monitoring deploy-portainer

# Default target
help:
	@echo "Raspberry Pi 5 Cluster Management"
	@echo "================================="
	@echo ""
	@echo "🏗️  Complete Deployment:"
	@echo "  deploy-all         - Complete cluster setup (all phases)"
	@echo "  deploy-infrastructure - Phase 2: Storage and ZFS setup"
	@echo "  deploy-platform   - Phase 3: Docker Swarm setup"
	@echo "  deploy-apps       - Phase 4: Deploy applications"
	@echo ""
	@echo "🔐 Security Management:"
	@echo "  deploy-ssh-keys   - Deploy SSH keys to all hosts"
	@echo "  deploy-ssh-dry    - Dry run SSH key deployment"
	@echo "  check-connectivity - Test SSH connectivity"
	@echo ""
	@echo "💾 Infrastructure Management:"
	@echo "  configure-storage - Configure ZFS and fast storage"
	@echo "  reboot-cluster    - Safely reboot cluster nodes"
	@echo ""
	@echo "🐳 Container Platform:"
	@echo "  setup-docker      - Setup Docker Swarm cluster"
	@echo ""
	@echo "📱 Applications:"
	@echo "  deploy-portainer  - Deploy Portainer management UI"
	@echo "  deploy-portainer-quick - Quick Portainer deployment (no waiting)"
	@echo ""
	@echo "📊 Monitoring:"
	@echo "  deploy-monitoring - Deploy Grafana & Prometheus monitoring"
	@echo "  deploy-monitoring-quick - Quick monitoring deployment/update"
	@echo "  deploy-advanced-dashboard - Deploy Node Exporter Full dashboard"
	@echo ""
	@echo "🛠️  Utilities:"
	@echo "  clean-backups     - Remove old backup files"
	@echo "  help              - Show this help message"

# Complete deployment workflows
deploy-all:
	@echo "🚀 Starting complete cluster deployment..."
	ansible-playbook site.yml

deploy-infrastructure:
	@echo "🏗️  Deploying infrastructure (storage, ZFS)..."
	ansible-playbook infrastructure/configure_storage.yml --limit cluster_nodes

deploy-platform:
	@echo "🐳 Setting up container platform..."
	ansible-playbook container-platform/setup_docker_swarm.yml --limit cluster_nodes

deploy-apps:
	@echo "📱 Deploying applications..."
	ansible-playbook applications/deploy_portainer.yml --limit manager_nodes

deploy-monitoring:
	@echo "📊 Deploying monitoring stack..."
	ansible-playbook applications/deploy_monitoring.yml --limit manager_nodes

deploy-monitoring-quick:
	@echo "🚀 Quick monitoring deployment/update..."
	ansible-playbook applications/deploy_monitoring_quick.yml --limit manager_nodes

deploy-advanced-dashboard:
	@echo "📊 Deploying Node Exporter Full dashboard..."
	ansible-playbook applications/deploy_advanced_dashboard.yml --limit manager_nodes

# Security management
deploy-ssh-keys:
	@echo "🔐 Deploying SSH keys to all hosts..."
	ansible-playbook security/populate_authorized_keys.yml

deploy-ssh-dry:
	@echo "🔍 Dry run - showing what would change..."
	ansible-playbook security/populate_authorized_keys.yml --check --diff

check-connectivity:
	@echo "🔗 Testing SSH connectivity..."
	ansible all -m ping

# Infrastructure management
configure-storage:
	@echo "💾 Configuring ZFS and fast storage..."
	ansible-playbook infrastructure/configure_storage.yml --limit cluster_nodes

reboot-cluster:
	@echo "🔄 Safely rebooting cluster nodes..."
	ansible-playbook reboot_cluster.yml 2>/dev/null || echo "⚠️  Reboot playbook not found"

# Container platform management
setup-docker:
	@echo "🐳 Setting up Docker Swarm cluster..."
	ansible-playbook container-platform/setup_docker_swarm.yml --limit cluster_nodes

# Application management
deploy-portainer:
	@echo "📱 Deploying Portainer management UI..."
	ansible-playbook applications/deploy_portainer.yml --limit manager_nodes

deploy-portainer-quick:
	@echo "🚀 Quick Portainer deployment/update..."
	ansible-playbook applications/deploy_portainer_quick.yml --limit manager_nodes

# Utilities
clean-backups:
	@echo "🧹 Cleaning up old backup files..."
	ansible all -m shell -a "find ~/.ssh -name 'authorized_keys.backup.*' -mtime +7 -delete" || true

# Legacy aliases for backward compatibility
deploy: deploy-ssh-keys
deploy-dry: deploy-ssh-dry
deploy-cluster: deploy-ssh-keys
setup-docker-swarm: setup-docker
