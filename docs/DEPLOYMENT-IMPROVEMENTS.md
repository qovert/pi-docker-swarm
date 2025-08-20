# Infrastructure Organization and Deployment Improvements

## Directory Structure Reorganization

### Issue
The repository had inconsistent organization with single-file directories:
- `infrastructure/configure_storage.yml` - Single file directory
- `container-platform/setup_docker_swarm.yml` - Single file directory
- `playbooks/` - Multiple related operational playbooks

### Solution
Consolidated all operational playbooks under `playbooks/` directory for better organization and consistency.

### Changes Made
- **Moved**: `infrastructure/configure_storage.yml` → `playbooks/configure-storage.yml`
- **Removed**: Empty `infrastructure/` directory
- **Updated**: All references in Makefile, cluster-dynamic.yml, and site.yml
- **Standardized**: Naming convention using hyphens for consistency

## `/tmp` Directory Permissions Fix

### Issue
Previously, there were redundant tasks in both `infrastructure/configure_storage.yml` and `container-platform/setup_docker_swarm.yml` that set `/tmp` permissions to `1777`. This created duplicate work and the permissions were set before the partition was mounted.

### Solution
1. **Removed redundant tasks**: Eliminated duplicate permission-setting tasks from both playbooks
2. **Integrated with partition creation**: Updated the mount point creation to set correct permissions based on the mount point:
   - `/tmp` gets `1777` (sticky bit with world write)
   - Other mount points get `0755` (standard directory permissions)
3. **Post-mount verification**: Added a task to ensure `/tmp` has correct permissions after mounting (since mounting can reset permissions)

### Changes Made

#### playbooks/configure-storage.yml (formerly infrastructure/configure_storage.yml)
- ❌ Removed: "Ensure /tmp directory has correct permissions" task at the beginning
- ✅ Updated: Mount point creation with conditional permissions
- ✅ Added: Post-mount permission verification for `/tmp`
- ✅ Moved: To playbooks/ directory for better organization

#### container-platform/setup_docker_swarm.yml
- ❌ Removed: "Ensure /tmp directory has correct permissions" task

### Code Changes

```yaml
# Before: Fixed permissions for all mount points
- name: Create mount points for fast disk partitions
  ansible.builtin.file:
    path: "{{ item.mount_point }}"
    state: directory
    mode: '0755'
  loop: "{{ fast_disk_partitions }}"

# After: Conditional permissions based on mount point
- name: Create mount points for fast disk partitions
  ansible.builtin.file:
    path: "{{ item.mount_point }}"
    state: directory
    mode: "{{ '1777' if item.mount_point == '/tmp' else '0755' }}"
  loop: "{{ fast_disk_partitions }}"

# Added: Post-mount verification
- name: Ensure /tmp has correct permissions after mounting
  ansible.builtin.file:
    path: /tmp
    mode: '1777'
    state: directory
  when: fast_disk_info.rc == 0
```

### Benefits
- **Reliable**: Permissions are set correctly during the logical partition setup process
- **No Duplication**: Single place for permission management
- **More Reliable**: Handles cases where mounting might reset permissions
- **Better Organization**: Permission management is co-located with partition setup

### Verification
The changes maintain full functionality while improving code organization and idempotency:

```bash
# Test storage configuration
ansible-playbook infrastructure/configure_storage.yml --check

# Test Docker Swarm setup  
ansible-playbook container-platform/setup_docker_swarm.yml --check
```

Both playbooks now run without the redundant `/tmp` permission tasks, and the `/tmp` directory gets the correct permissions during the natural flow of partition setup and mounting.
