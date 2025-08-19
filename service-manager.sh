#!/bin/bash
# =============================================================================
# Pi Docker Swarm Service Manager
# =============================================================================
# Easy CLI tool for managing Docker Swarm services
# Usage: ./service-manager.sh [command] [service]
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_FILE="$SCRIPT_DIR/services.yml"
STACK_MGT_PLAYBOOK="$SCRIPT_DIR/playbooks/stack-management.yml"
DYNAMIC_SERVICES_PLAYBOOK="$SCRIPT_DIR/playbooks/dynamic-services.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to show usage
show_usage() {
    print_color $BLUE "Pi Docker Swarm Service Manager"
    print_color $BLUE "==============================="
    echo ""
    print_color $GREEN "🚀 Service Management:"
    echo "  $0 deploy [service]     - Deploy specific service"
    echo "  $0 remove [service]     - Remove specific service"
    echo "  $0 restart [service]    - Restart specific service"
    echo "  $0 status [service]     - Get service status"
    echo "  $0 logs [service]       - View service logs"
    echo ""
    print_color $GREEN "📋 Information:"
    echo "  $0 list                 - List all available services"
    echo "  $0 list-enabled         - List enabled services only"
    echo "  $0 list-running         - List currently running services"
    echo "  $0 cluster-status       - Show complete cluster status"
    echo ""
    print_color $GREEN "💡 Examples:"
    echo "  $0 deploy monitoring"
    echo "  $0 status portainer"
    echo "  $0 logs monitoring"
    echo "  $0 remove portainer"
    echo ""
    print_color $GREEN "💡 For cluster-wide operations, use make:"
    echo "  make deploy-services    - Deploy all enabled services"
    echo "  make deploy-all         - Complete cluster deployment"
}

# Function to check if service exists
check_service_exists() {
    local service=$1
    if ! grep -q "^  $service:" "$SERVICES_FILE"; then
        print_color $RED "❌ Error: Service '$service' not found in services.yml"
        echo ""
        print_color $YELLOW "Available services:"
        list_services
        exit 1
    fi
}

# Function to list all services
list_services() {
    print_color $BLUE "📋 Available Services:"
    echo ""
    
    # Extract services from YAML - look for services under the services: section
    awk '
    BEGIN { in_services = 0; service = ""; desc = "" }
    /^services:/ { in_services = 1; next }
    /^[a-zA-Z]/ && in_services == 1 { in_services = 0 }
    in_services == 1 && /^  [a-zA-Z][a-zA-Z0-9_-]*:/ {
        if (service != "" && desc != "") {
            print service "||" desc
        }
        gsub(/^  /, "", $0)
        gsub(/:.*$/, "", $0)
        service = $0
        desc = ""
    }
    in_services == 1 && /description:/ {
        gsub(/.*description: *"?/, "", $0)
        gsub(/".*$/, "", $0)
        desc = $0
    }
    END {
        if (service != "" && desc != "") {
            print service "||" desc
        }
    }
    ' "$SERVICES_FILE" | while IFS='||' read -r service description; do
        if [ -n "$service" ]; then
            # Check if enabled
            enabled=$(awk -v svc="$service" '
            BEGIN { in_service = 0 }
            $0 ~ "^  " svc ":$" { in_service = 1; next }
            /^  [a-zA-Z]/ && in_service == 1 { in_service = 0 }
            in_service == 1 && /enabled:/ { 
                gsub(/.*enabled: */, "", $0)
                print $0
                exit
            }
            ' "$SERVICES_FILE")
            
            if [ "$enabled" = "true" ]; then
                status_icon="✅"
            else
                status_icon="⚪"
            fi
            printf "  %s %-15s %s\n" "$status_icon" "$service:" "$description"
        fi
    done
}

# Function to list enabled services
list_enabled_services() {
    print_color $BLUE "📋 Enabled Services:"
    echo ""
    
    # Extract enabled services from YAML
    awk '
    BEGIN { in_services = 0; service = ""; desc = ""; enabled = "" }
    /^services:/ { in_services = 1; next }
    /^[a-zA-Z]/ && in_services == 1 { in_services = 0 }
    in_services == 1 && /^  [a-zA-Z][a-zA-Z0-9_-]*:/ {
        if (service != "" && desc != "" && enabled == "true") {
            print service "||" desc
        }
        gsub(/^  /, "", $0)
        gsub(/:.*$/, "", $0)
        service = $0
        desc = ""
        enabled = ""
    }
    in_services == 1 && /description:/ {
        gsub(/.*description: *"?/, "", $0)
        gsub(/".*$/, "", $0)
        desc = $0
    }
    in_services == 1 && /enabled:/ {
        gsub(/.*enabled: */, "", $0)
        enabled = $0
    }
    END {
        if (service != "" && desc != "" && enabled == "true") {
            print service "||" desc
        }
    }
    ' "$SERVICES_FILE" | while IFS='||' read -r service description; do
        if [ -n "$service" ]; then
            printf "  ✅ %-15s %s\n" "$service:" "$description"
        fi
    done
}

# Function to list running services
list_running_services() {
    print_color $BLUE "📋 Running Docker Stacks:"
    echo ""
    if ansible manager_nodes -m shell -a "docker stack ls" -o 2>/dev/null | tail -n +2 | head -1 | grep -q "NAME"; then
        ansible manager_nodes -m shell -a "docker stack ls" -o 2>/dev/null | \
        tail -n +2 | while read line; do
            echo "  🐳 $line"
        done
    else
        echo "  ⚪ No Docker stacks currently running"
    fi
}

# Function to show cluster status
show_cluster_status() {
    print_color $BLUE "🏗️ Complete Cluster Status"
    print_color $BLUE "=========================="
    echo ""
    
    print_color $GREEN "🐳 Docker Swarm Nodes:"
    if ansible manager_nodes -m shell -a "docker node ls" -o 2>/dev/null | tail -n +2 | head -1 | grep -q "ID"; then
        ansible manager_nodes -m shell -a "docker node ls" -o 2>/dev/null | tail -n +2 | while read line; do
            echo "  $line"
        done
    else
        echo "  ⚠️  Unable to connect to Docker Swarm"
    fi
    
    echo ""
    print_color $GREEN "📦 Running Stacks:"
    list_running_services | tail -n +3
    
    echo ""
    print_color $GREEN "🔧 Services:"
    if ansible manager_nodes -m shell -a "docker service ls" -o 2>/dev/null | tail -n +2 | head -1 | grep -q "ID"; then
        ansible manager_nodes -m shell -a "docker service ls" -o 2>/dev/null | tail -n +2 | while read line; do
            echo "  $line"
        done
    else
        echo "  ⚪ No Docker services currently running"
    fi
}

# Main script logic
case "${1:-}" in
    "deploy")
        if [ -z "${2:-}" ]; then
            print_color $RED "❌ Error: Service name required"
            echo "Usage: $0 deploy [service]"
            exit 1
        fi
        check_service_exists "$2"
        print_color $BLUE "🚀 Deploying service: $2"
        ansible-playbook "$STACK_MGT_PLAYBOOK" -e "operation=deploy service=$2"
        ;;
    
    "remove")
        if [ -z "${2:-}" ]; then
            print_color $RED "❌ Error: Service name required"
            echo "Usage: $0 remove [service]"
            exit 1
        fi
        check_service_exists "$2"
        print_color $YELLOW "⚠️  WARNING: This will remove service '$2' and all its containers"
        read -p "Are you sure? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_color $BLUE "🗑️ Removing service: $2"
            ansible-playbook "$STACK_MGT_PLAYBOOK" -e "operation=remove service=$2"
        else
            print_color $YELLOW "Operation cancelled"
        fi
        ;;
    
    "restart")
        if [ -z "${2:-}" ]; then
            print_color $RED "❌ Error: Service name required"
            echo "Usage: $0 restart [service]"
            exit 1
        fi
        check_service_exists "$2"
        print_color $BLUE "🔄 Restarting service: $2"
        ansible-playbook "$STACK_MGT_PLAYBOOK" -e "operation=restart service=$2"
        ;;
    
    "status")
        if [ -z "${2:-}" ]; then
            print_color $RED "❌ Error: Service name required"
            echo "Usage: $0 status [service]"
            exit 1
        fi
        check_service_exists "$2"
        print_color $BLUE "📊 Getting status for service: $2"
        ansible-playbook "$STACK_MGT_PLAYBOOK" -e "operation=status service=$2"
        ;;
    
    "logs")
        if [ -z "${2:-}" ]; then
            print_color $RED "❌ Error: Service name required"
            echo "Usage: $0 logs [service]"
            exit 1
        fi
        check_service_exists "$2"
        print_color $BLUE "📜 Getting logs for service: $2"
        ansible-playbook "$STACK_MGT_PLAYBOOK" -e "operation=logs service=$2"
        ;;
    
    "list")
        list_services
        ;;
    
    "list-enabled")
        list_enabled_services
        ;;
    
    "list-running")
        list_running_services
        ;;
    
    "cluster-status")
        show_cluster_status
        ;;
    
    "help"|"-h"|"--help"|"")
        show_usage
        ;;
    
    *)
        print_color $RED "❌ Error: Unknown command '$1'"
        echo ""
        show_usage
        exit 1
        ;;
esac
