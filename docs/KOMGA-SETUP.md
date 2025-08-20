# Komga Service Setup Guide

## Overview
This guide explains how to deploy Komga, a comic and manga server, with multi-node ZFS data synchronization on your Pi Docker Swarm cluster.

## Features
- **ZFS Dataset**: Dedicated `tank/komga` dataset with optimized settings for large files
- **Multi-node Sync**: Automatic synchronization between cluster nodes using syncoid
- **Docker Swarm**: Scalable deployment with resource limits and restart policies
- **Persistent Storage**: Comics and configuration data preserved across restarts

## Deployment Steps

### 1. Complete Cluster Setup (if not already done)
```bash
make deploy-all
```

### 2. Deploy Komga Service
```bash
# Option A: Deploy just Komga
./service-manager.sh deploy komga

# Option B: Deploy all enabled services
make deploy-services
```

### 3. Setup ZFS Dataset (if needed manually)
```bash
# Create ZFS datasets on all nodes
make setup-zfs-datasets

# Or for just Komga
./service-manager.sh setup-zfs komga
```

### 4. Configure Syncoid Synchronization
```bash
# Setup syncoid for data synchronization
make setup-syncoid

# Or for just Komga
./service-manager.sh setup-sync komga
```

## Service Configuration

### ZFS Dataset
- **Name**: `tank/komga`
- **Mountpoint**: `/data/komga`
- **Compression**: LZ4 (efficient for comics)
- **Record Size**: 128K (optimized for large files)
- **Atime**: Disabled (performance)

### Syncoid Synchronization
- **Frequency**: Every 15 minutes
- **Method**: ZFS snapshots with incremental sync using existing SSH keys
- **Direction**: Bidirectional between all cluster nodes
- **Logs**: `/var/log/syncoid-komga.log`
- **SSH**: Uses existing passwordless SSH authentication (no additional keys needed)

### Docker Service
- **Image**: `gotson/komga:latest`
- **Port**: 8080
- **Memory Limit**: 1.5GB
- **Memory Reservation**: 512MB
- **Restart Policy**: On failure (max 3 attempts)

## Directory Structure
```
/data/komga/
├── config/          # Komga configuration and database
├── data/            # Application data
└── library/         # Comic/manga files (read-only mount)
```

## Management Commands

### Service Management
```bash
# Check service status
./service-manager.sh status komga

# View service logs
./service-manager.sh logs komga

# Restart service
./service-manager.sh restart komga

# Remove service
./service-manager.sh remove komga
```

### Synchronization Management
```bash
# Check sync status
./service-manager.sh sync-status

# Manual sync trigger (run on any node)
/usr/local/bin/sync-komga.sh

# View sync logs
tail -f /var/log/syncoid-komga.log
```

### Storage Management
```bash
# Check ZFS dataset status
zfs list tank/komga

# Check dataset usage
zfs list -o name,used,avail,mountpoint tank/komga

# View snapshots
zfs list -t snapshot tank/komga
```

## Access Komga

1. **Web Interface**: http://[cluster-ip]:8080
2. **Initial Setup**: Follow Komga's setup wizard
3. **Library Path**: Configure library to scan `/library`

## Adding Comics/Manga

1. **Upload Method**: Copy files to `/data/komga/library/` on any node
2. **Sync**: Files will automatically sync to other nodes within 15 minutes
3. **Scan**: Trigger library scan in Komga web interface

## Troubleshooting

### Service Issues
```bash
# Check Docker service status
docker service ls | grep komga
docker service logs -f komga_komga

# Check container placement
docker service ps komga_komga
```

### Sync Issues
```bash
# Check syncoid logs
tail -f /var/log/syncoid-komga.log

# Manual sync test
/usr/local/bin/sync-komga.sh

# Check SSH connectivity (uses existing SSH setup)
ssh root@[other-node] 'echo SSH test successful'

# Check cron jobs
crontab -l | grep -E "(sanoid|syncoid)"
```

### Storage Issues
```bash
# Check ZFS health
zpool status tank

# Check dataset health
zfs list tank/komga

# Check mount status
mount | grep komga
```

## Configuration Files

- **Service Definition**: `services.yml` (komga section)
- **Docker Stack**: `applications/stacks/komga-stack.yml`
- **ZFS Management**: `playbooks/manage-zfs-datasets.yml`
- **Syncoid Setup**: `playbooks/setup-syncoid.yml`

## Notes

- **Safe to re-run**: All operations can be run multiple times safely
- **No duplication**: Single configuration per service
- **Extensible**: Add new services by editing `services.yml`
- **Backup**: ZFS snapshots provide automatic backup/rollback capability
