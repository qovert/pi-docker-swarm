# Raspberry Pi 5 Cluster Management

Automated dep- **Portainer UI**: `https://[manager-ip]:9443`
- **SSH**: `ssh ditto@[node-ip]`
- **Docker CLI**: Available on all nodes

## 🔄 Maintenancent and management for a Raspberry Pi 5 cluster with ZFS storage and Docker Swarm orchestration. All playbooks are fully idempotent and can be run multiple times safely.

## 🚀 Quick Start

```bash
# Complete cluster deployment
make deploy-all

# Or deploy phases individually
make deploy-ssh-keys        # SSH keys and security
make deploy-infrastructure  # ZFS storage configuration  
make deploy-platform       # Docker Swarm cluster
make deploy-apps           # Portainer and applications
```

## 🏗️ Architecture

**Hardware**: 3x Raspberry Pi 5 (8GB RAM) with 4x 512GB SATA SSDs + 1x 120GB NVMe per node

**Storage**: 
- ZFS RAIDZ1 pool (~1.3TB usable) for Docker and application data
- NVMe SSD for logs, cache, tmp, and swap

**Platform**: Docker Swarm with Portainer management UI

## ⚙️ Configuration

1. **Update inventory**: Edit `environments/production/inventory.yml` with your node IPs
2. **Configure variables**: Copy and edit `environments/production/group_vars/all.yml.example` → `all.yml`
3. **Change passwords**: Update `grafana_admin_password` and other credentials
4. **SSH keys**: Add your public keys to `security/ssh_keys/`

## 📋 Commands


**Deployment**:
- `make deploy-all` - Complete cluster setup
- `make deploy-infrastructure` - ZFS storage only
- `make deploy-platform` - Docker Swarm only
- `make deploy-apps` - Applications only

**Management**:
- `make deploy-ssh-keys` - Deploy SSH access
- `make reboot-cluster` - Safe cluster reboot
- `make clean-backups` - Remove old backups

## 🎯 Access Points

- **Portainer UI**: `https://[manager-ip]:9443`
- **SSH**: `ssh ditto@[node-ip]`
- **Docker CLI**: Available on all nodes

## � Maintenance

```bash
# Check cluster status
ansible manager_nodes -m shell -a "docker node ls"

# View service logs
docker service logs [service-name]

# Storage health
ansible cluster_nodes -m shell -a "zpool status"
```

## ✨ Features

- **Fully Idempotent**: All playbooks can run multiple times safely
- **ZFS Storage**: Automated RAIDZ1 setup with compression
- **Container Platform**: Production-ready Docker Swarm
- **Web Management**: Portainer for visual cluster management
- **Professional Structure**: Clean, maintainable Ansible code
