# Pi Docker Swarm Quick Start Guide

## 🚀 Dynamic Service Management System

Your Pi Docker Swarm cluster now supports fully dynamic, extensible service management without needing to touch Portainer's web interface. All services are managed through code!

## 📋 How to Add New Services

1. **Edit `services.yml`** - Add your new service definition:
```yaml
services:
  your-new-service:
    description: "Description of your service"
    enabled: true
    stack_file: "your-new-service-stack.yml"
    data_directories:
      - /opt/docker-data/your-service/data
      - /opt/docker-data/your-service/config
    config_files:
      - src: "config/your-service.yml"
        dest: "/opt/docker-data/your-service/config/config.yml"
    health_check:
      enabled: true
      url: "http://localhost:8080/health"
      timeout: 30
```

2. **Create stack file** in `applications/stacks/your-new-service-stack.yml`

3. **Deploy the service**:
```bash
./service-manager.sh deploy your-new-service
```

That's it! No code changes needed.

## 🛠️ Command Quick Reference

### Easy Service Manager CLI
```bash
# Deploy services
./service-manager.sh deploy monitoring          # Deploy specific service
./service-manager.sh deploy-all                 # Deploy all enabled services

# Manage services
./service-manager.sh status portainer           # Check service status
./service-manager.sh logs monitoring            # View service logs
./service-manager.sh restart portainer          # Restart service
./service-manager.sh remove monitoring          # Remove service

# Information
./service-manager.sh list                       # List all services
./service-manager.sh list-enabled               # List enabled services only
./service-manager.sh list-running               # List running Docker stacks
./service-manager.sh cluster-status             # Complete cluster overview

# Full cluster deployment
./service-manager.sh cluster-deploy             # Deploy entire cluster
```

### Advanced Makefile Commands
```bash
# Dynamic service management
make deploy-services                           # Deploy all enabled services
make deploy-service SERVICE=monitoring        # Deploy specific service
make remove-service SERVICE=portainer         # Remove specific service
make restart-service SERVICE=monitoring       # Restart specific service
make service-status SERVICE=portainer         # Get service status
make service-logs SERVICE=monitoring          # View service logs

# Cluster management
make deploy-cluster-dynamic                    # Deploy cluster with dynamic services
make cluster-status                           # Show cluster status
```

## 🎯 Key Benefits

1. **No More Portainer GUI Dependency** - Everything is managed through code
2. **Fully Extensible** - Add new services by just editing YAML files
3. **Version Controlled** - All service configurations are in Git
4. **Idempotent** - Safe to run repeatedly
5. **Easy CLI** - Simple commands for all operations
6. **Health Monitoring** - Built-in health checks for services

## 📁 Service Configuration Structure

```yaml
services:
  service-name:
    description: "What this service does"
    enabled: true|false                        # Whether to deploy
    stack_file: "stack-filename.yml"           # Docker Compose stack file
    data_directories:                          # Directories to create
      - /opt/docker-data/service/data
    config_files:                              # Config files to deploy
      - src: "config/file.yml"
        dest: "/opt/target/file.yml"
    health_check:                              # Health monitoring
      enabled: true
      url: "http://localhost:port/health"
      timeout: 30
    dependencies:                              # Service dependencies
      - other-service-name
```

## 🔄 Migration from Portainer

1. **Remove existing Portainer-managed stacks** through Portainer UI
2. **Add stack definitions** to `services.yml`
3. **Deploy through new system**:
   ```bash
   ./service-manager.sh deploy-all
   ```
4. **Disable Portainer** by setting `enabled: false` in `services.yml`

## 🚨 Example Workflow

1. **Check what's running**:
   ```bash
   ./service-manager.sh cluster-status
   ```

2. **Add a new monitoring stack**:
   - Edit `services.yml` to add your monitoring service
   - Create `applications/stacks/monitoring-stack.yml`
   - Deploy: `./service-manager.sh deploy monitoring`

3. **Update existing service**:
   - Edit the stack file in `applications/stacks/`
   - Redeploy: `./service-manager.sh restart service-name`

4. **Remove service**:
   ```bash
   ./service-manager.sh remove service-name
   ```

## 🎉 You're Ready!

Your Pi Docker Swarm cluster is now fully code-managed and infinitely extensible. No more manual Docker Compose deployments or Portainer web interface dependencies!
