# Makefile for Raspberry Pi 5 Cluster Management

.PHONY: help deploy deploy-dry check-connectivity clean-backups deploy-all deploy-infrastructure deploy-platform deploy-services setup-docker service-cli

# Default target
help:
	@echo "Raspberry Pi 5 Cluster Management"
	@echo "================================="
	@echo ""
	@echo "🏗️  Complete Deployment:"
	@echo "  deploy-all         - Complete cluster setup (all phases)"
	@echo "  deploy-infrastructure - Phase 2: Storage and ZFS setup"
	@echo "  deploy-platform   - Phase 3: Docker Swarm setup"
	@echo "  deploy-services   - Phase 4: Deploy all enabled services"
	@echo ""
	@echo "🔐 Security Management:"
	@echo "  setup-cluster-ssh - Setup passwordless SSH between cluster nodes"
	@echo "  deploy-ssh-keys   - Deploy SSH keys to all hosts"
	@echo "  deploy-ssh-dry    - Dry run SSH key deployment"
	@echo ""
	@echo "💾 Infrastructure Management:"
	@echo "  configure-storage - Configure ZFS and fast storage"
	@echo "  reboot-cluster    - Safely reboot cluster nodes"
	@echo ""
	@echo "🐳 Container Platform:"
	@echo "  setup-docker      - Setup Docker Swarm cluster"
	@echo ""
	@echo "🚀 Service Management (Dynamic):"
	@echo "  service-cli       - Launch interactive service manager CLI"
	@echo "  deploy-services   - Deploy all enabled services from services.yml"
	@echo ""
	@echo "🗄️  Storage & Sync Management:"
	@echo "  setup-zfs-datasets - Create ZFS datasets for services"
	@echo "  setup-syncoid     - Configure syncoid for data synchronization"
	@echo "  sync-status       - Check syncoid synchronization status"
	@echo ""
	@echo "🔍 Verification & Testing:"
	@echo "  verify-komga      - Verify Komga service setup"
	@echo ""
	@echo "💡 For individual service management, use: ./service-manager.sh"
	@echo "   Examples: ./service-manager.sh deploy monitoring"
	@echo "            ./service-manager.sh list"
	@echo "            ./service-manager.sh cluster-status"
	@echo ""
	@echo "🛠️  Utilities:"
	@echo "  clean-backups     - Remove old backup files"
	@echo "  help              - Show this help message"

# Complete deployment workflows
deploy-all:
	@echo "🚀 Starting complete cluster deployment..."
	ansible-playbook cluster-dynamic.yml

deploy-infrastructure:
	@echo "🏗️  Deploying infrastructure (storage, ZFS)..."
	ansible-playbook playbooks/configure-storage.yml --limit cluster_nodes

deploy-platform:
	@echo "🐳 Setting up Docker Swarm platform..."
	ansible-playbook container-platform/setup_docker_swarm.yml

# New dynamic service management
deploy-services:
	@echo "🚀 Deploying all enabled services from services.yml..."
	ansible-playbook playbooks/dynamic-services.yml

setup-zfs-datasets:
	@echo "🗄️  Creating ZFS datasets for services..."
	ansible-playbook playbooks/manage-zfs-datasets.yml

setup-syncoid:
	@echo "🔄 Setting up syncoid for data synchronization..."
	ansible-playbook playbooks/setup-syncoid.yml

sync-status:
	@echo "📊 Checking syncoid synchronization status..."
	@./service-manager.sh sync-status

service-cli:
	@echo "🚀 Launching service manager CLI..."
	@./service-manager.sh

verify-komga:
	@echo "🔍 Verifying Komga service setup..."
	@./verify-komga-setup.sh

# Security management
setup-cluster-ssh:
	@echo "🔐 Setting up passwordless SSH between cluster nodes..."
	ansible-playbook playbooks/setup-cluster-ssh.yml

deploy-ssh-keys:
	@echo "🔐 Deploying SSH keys to all hosts..."
	ansible-playbook security/populate_authorized_keys.yml

deploy-ssh-dry:
	@echo "🔍 Dry run - showing what would change..."
	ansible-playbook security/populate_authorized_keys.yml --check --diff

# Infrastructure management
configure-storage:
	@echo "💾 Configuring ZFS and fast storage..."
	ansible-playbook playbooks/configure-storage.yml --limit cluster_nodes

reboot-cluster:
	@echo "🔄 Safely rebooting cluster nodes..."
	ansible-playbook reboot_cluster.yml 2>/dev/null || echo "⚠️  Reboot playbook not found"

# Container platform management
setup-docker:
	@echo "🐳 Setting up Docker Swarm cluster..."
	ansible-playbook container-platform/setup_docker_swarm.yml --limit cluster_nodes

# Utilities
clean-backups:
	@echo "🧹 Cleaning up old backup files..."
	ansible all -m shell -a "find ~/.ssh -name 'authorized_keys.backup.*' -mtime +7 -delete" || true

# Legacy aliases for backward compatibility
deploy: deploy-ssh-keys
deploy-dry: deploy-ssh-dry
