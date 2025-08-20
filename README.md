# Raspberry Pi 5 Cluster Management

Automated deployment and management for a Raspberry Pi 5 cluster with ZFS storage and Docker Swarm orchestration. Fully idempotent Infrastructure-as-Code solution with extensible service management.

## 🚀 Quick Start

```bash
# Complete cluster deployment
make deploy-all

# Or deploy phases individually
make deploy-ssh-keys        # SSH keys and security
make deploy-infrastructure  # ZFS storage configuration  
make deploy-platform       # Docker Swarm cluster
make deploy-services        # Deploy all services from services.yml
```

## 🎯 Service Management

This cluster uses a **dynamic service management system** with a clean, non-redundant interface:

### **Makefile** - High-level cluster operations:
```bash
make deploy-all              # Complete cluster deployment
make deploy-services         # Deploy all enabled services
make service-cli             # Launch interactive service manager
```

### **Service Manager CLI** - Detailed service operations:
```bash
./service-manager.sh deploy monitoring     # Deploy specific service
./service-manager.sh remove monitoring     # Remove specific service
./service-manager.sh restart monitoring    # Restart specific service
./service-manager.sh status monitoring     # Check service status  
./service-manager.sh logs monitoring       # View service logs
./service-manager.sh list                  # List all services
./service-manager.sh cluster-status        # Complete cluster overview
```

### Adding New Services
1. **Edit `services.yml`** - Add your service definition:
```yaml
services:
  your-service:
    description: "Your awesome service"
    enabled: true
    stack_file: "your-service-stack.yml"
    data_directories:
      - /opt/docker-data/your-service/data
    health_check:
      enabled: true
      url: "http://localhost:8080/health"
```

2. **Create stack file** - Add Docker Compose file in `applications/stacks/`
3. **Deploy** - `./service-manager.sh deploy your-service`

**That's it!** No code changes needed.

## 🏗️ Architecture

**Hardware**: 
- 3x Raspberry Pi 5 (8GB RAM) 
- Radxa SATA Pi Hat with 4x 512GB SATA SSDs + 1x 120GB NVMe per node

**Storage**: 
- ZFS RAIDZ1 pool for Docker and application data
- SSD for logs, cache, tmp, and swap

**Platform**: RaspOS with docker swarm

## ⚙️ Configuration

1. **Update inventory**: Edit `environments/production/inventory.yml` with your node IPs
2. **Configure variables**: Copy and edit `environments/production/group_vars/all.yml.example` → `all.yml`
3. **Change passwords**: Update `grafana_admin_password` and other credentials
4. **SSH keys**: Add your public keys to `security/ssh_keys/`
5. **Services**: Edit `services.yml` to enable/disable services

## 📋 Commands

**Complete Deployment**:
- `make deploy-all` - Complete cluster setup with dynamic services
- `make deploy-infrastructure` - ZFS storage only
- `make deploy-platform` - Docker Swarm only
- `make deploy-services` - All enabled services from services.yml

**Service Management**:
- `./service-manager.sh list` - Show all available services
- `./service-manager.sh deploy [service]` - Deploy specific service
- `./service-manager.sh remove [service]` - Remove service (with confirmation)
- `./service-manager.sh restart [service]` - Restart service
- `./service-manager.sh status [service]` - Get service status
- `./service-manager.sh logs [service]` - View service logs

**Cluster Management**:
- `make deploy-ssh-keys` - Deploy SSH access
- `make check-connectivity` - Test SSH connectivity
- `make reboot-cluster` - Safe cluster reboot
- `make clean-backups` - Remove old backups

## 🎯 Access Points

- **SSH**: `ssh ditto@[node-ip]`
- **Docker CLI**: Available on all nodes
- **Service UIs**: Check service configurations in `services.yml`

## 🔄 Maintenance

```bash
# Check cluster status
./service-manager.sh cluster-status

# Individual service status
./service-manager.sh status monitoring

# View service logs  
./service-manager.sh logs monitoring

# Deploy all services
make deploy-services

# Storage health
ansible cluster_nodes -m shell -a "zpool status"
```

## ✨ Key Features

- **🔄 Fully Idempotent**: All playbooks can run multiple times safely
- **💾 ZFS Storage**: Automated RAIDZ1 setup with compression  
- **🐳 Container Platform**: Production-ready Docker Swarm
- **🚀 Dynamic Services**: Add services by editing YAML only
- **📋 Easy CLI**: Simple commands for all operations
- **📊 Health Monitoring**: Built-in health checks for services
- **🎯 No GUI Dependency**: Everything managed through code
- **📁 Version Controlled**: All configurations in Git

## � Complete Infrastructure-as-Code Solution

This system provides complete Docker Swarm lifecycle management through code:

1. **Define services** in `services.yml` 
2. **Deploy**: `./service-manager.sh deploy-all`
3. **Manage**: All through CLI and code

