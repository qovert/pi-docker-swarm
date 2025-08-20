#!/bin/bash
# =============================================================================
# Komga Setup Verification Script
# =============================================================================
# This script verifies that the Komga service is properly configured with
# ZFS datasets and syncoid synchronization
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "ok" ]; then
        echo -e "${GREEN}✅ ${message}${NC}"
    elif [ "$status" = "warn" ]; then
        echo -e "${YELLOW}⚠️  ${message}${NC}"
    else
        echo -e "${RED}❌ ${message}${NC}"
    fi
}

print_header() {
    echo -e "${BLUE}$1${NC}"
    echo "============================================"
}

# Test 1: Check if Komga is in services.yml
print_header "Testing Komga Service Configuration"
if grep -q "komga:" "$SCRIPT_DIR/services.yml"; then
    print_status "ok" "Komga service found in services.yml"
else
    print_status "error" "Komga service not found in services.yml"
    exit 1
fi

# Test 2: Check if stack file exists
if [ -f "$SCRIPT_DIR/applications/stacks/komga-stack.yml" ]; then
    print_status "ok" "Komga stack file exists"
else
    print_status "error" "Komga stack file missing"
fi

# Test 3: Check ZFS dataset playbook
print_header "Testing ZFS Dataset Management"
if [ -f "$SCRIPT_DIR/playbooks/manage-zfs-datasets.yml" ]; then
    print_status "ok" "ZFS dataset management playbook exists"
else
    print_status "error" "ZFS dataset management playbook missing"
fi

# Test 4: Check syncoid playbook
print_header "Testing Syncoid Configuration"
if [ -f "$SCRIPT_DIR/playbooks/setup-syncoid.yml" ]; then
    print_status "ok" "Syncoid setup playbook exists"
else
    print_status "error" "Syncoid setup playbook missing"
fi

# Test 5: Check service manager commands
print_header "Testing Service Manager Commands"
if ./service-manager.sh list | grep -q "komga"; then
    print_status "ok" "Komga appears in service manager"
else
    print_status "warn" "Komga not visible in service manager (check AWK script)"
fi

# Test 6: Validate Ansible syntax
print_header "Testing Ansible Playbook Syntax"
echo "Checking ZFS dataset playbook syntax..."
if ansible-playbook playbooks/manage-zfs-datasets.yml --syntax-check >/dev/null 2>&1; then
    print_status "ok" "ZFS dataset playbook syntax valid"
else
    print_status "error" "ZFS dataset playbook has syntax errors"
fi

echo "Checking syncoid playbook syntax..."
if ansible-playbook playbooks/setup-syncoid.yml --syntax-check >/dev/null 2>&1; then
    print_status "ok" "Syncoid playbook syntax valid"
else
    print_status "error" "Syncoid playbook has syntax errors"
fi

# Test 7: Check documentation
print_header "Testing Documentation"
if [ -f "$SCRIPT_DIR/docs/KOMGA-SETUP.md" ]; then
    print_status "ok" "Komga setup documentation exists"
else
    print_status "warn" "Komga setup documentation missing"
fi

# Test 8: Check SSH connectivity (if cluster is accessible)
print_header "Testing SSH Connectivity (optional)"
if ansible all -m ping --one-line >/dev/null 2>&1; then
    print_status "ok" "SSH connectivity to cluster verified"
    
    # Test ZFS datasets (dry run)
    echo "Testing ZFS dataset creation (check mode)..."
    if ansible-playbook playbooks/manage-zfs-datasets.yml --check >/dev/null 2>&1; then
        print_status "ok" "ZFS dataset creation playbook runs successfully"
    else
        print_status "warn" "ZFS dataset creation has issues (check logs)"
    fi
    
    # Test syncoid setup (dry run)
    echo "Testing syncoid setup (check mode)..."
    if ansible-playbook playbooks/setup-syncoid.yml --check >/dev/null 2>&1; then
        print_status "ok" "Syncoid setup playbook runs successfully"
    else
        print_status "warn" "Syncoid setup has issues (check logs)"
    fi
else
    print_status "warn" "Cluster not accessible - skipping live tests"
fi

print_header "Verification Complete"
echo -e "${GREEN}Komga service setup verification complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Deploy ZFS datasets: make setup-zfs-datasets"
echo "2. Setup syncoid: make setup-syncoid"
echo "3. Deploy Komga: ./service-manager.sh deploy komga"
echo "4. Access Komga at: http://[cluster-ip]:8080"
