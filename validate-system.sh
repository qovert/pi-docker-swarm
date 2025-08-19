#!/bin/bash
# =============================================================================
# Validation Script - Test All Ansible Playbooks
# =============================================================================

set -e

echo "🔍 Validating all Ansible playbooks..."
echo ""

# Test main cluster orchestrator
echo "📋 Testing cluster-dynamic.yml..."
ansible-playbook cluster-dynamic.yml --syntax-check
echo "✅ cluster-dynamic.yml - PASSED"
echo ""

# Test dynamic services
echo "📋 Testing playbooks/dynamic-services.yml..."
ansible-playbook playbooks/dynamic-services.yml --syntax-check
echo "✅ dynamic-services.yml - PASSED"
echo ""

# Test stack management
echo "📋 Testing playbooks/stack-management.yml..."
ansible-playbook playbooks/stack-management.yml --syntax-check
echo "✅ stack-management.yml - PASSED"
echo ""

# Test service manager CLI
echo "📋 Testing service-manager.sh..."
./service-manager.sh list > /dev/null
echo "✅ service-manager.sh - PASSED"
echo ""

# Test Makefile
echo "📋 Testing Makefile..."
make help > /dev/null
echo "✅ Makefile - PASSED"
echo ""

echo "🎉 All validation tests PASSED!"
echo ""
echo "✅ System is ready for deployment:"
echo "   make deploy-all"
echo "   ./service-manager.sh list"
echo ""
