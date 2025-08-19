# Configuration Guide

## Quick Setup

1. **Copy example configuration**:
   ```bash
   cp environments/production/group_vars/all.yml.example environments/production/group_vars/all.yml
   ```

2. **Edit your configuration**:
   ```bash
   vim environments/production/group_vars/all.yml
   ```

3. **Update inventory with your node IPs**:
   ```bash
   vim environments/production/inventory.yml
   ```

## Key Settings

### Security (Required Changes)
```yaml
grafana_admin_password: "YourSecurePassword123!"  # CHANGE THIS!
```

### Network
```yaml
docker_swarm_interface: eth0  # Your cluster network interface
```

### Storage
```yaml
zfs_pool_name: tank
zfs_devices:
  - /dev/sdb  # Update for your disk layout
  - /dev/sdc
  - /dev/sdd
  - /dev/sda
fast_disk_device: /dev/sde
```

### Data Paths
```yaml
monitoring_data_path: "/data/monitoring"
portainer_data_path: "/data/portainer"
```

## Multi-Environment Support

Create different configurations for different environments:

```
environments/
├── development/group_vars/all.yml
├── staging/group_vars/all.yml
└── production/group_vars/all.yml
```

Deploy with: `ansible-playbook -i environments/staging/inventory.yml site.yml`
