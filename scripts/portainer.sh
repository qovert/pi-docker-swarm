#!/bin/bash

# Portainer Management Script for Docker Swarm
# This script provides easy management of Portainer deployment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK_NAME="portainer"
STACK_FILE="stacks/portainer-stack.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo "Usage: $0 {deploy|status|logs|remove|update|help}"
    echo ""
    echo "Commands:"
    echo "  deploy  - Deploy Portainer to Docker Swarm"
    echo "  status  - Show Portainer service status"
    echo "  logs    - Show Portainer service logs"
    echo "  remove  - Remove Portainer from Docker Swarm"
    echo "  update  - Update Portainer to latest version"
    echo "  help    - Show this help message"
}

check_swarm() {
    if ! docker info --format '{{.Swarm.LocalNodeState}}' | grep -q "active"; then
        echo -e "${RED}Error: Docker Swarm is not active on this node${NC}"
        exit 1
    fi
}

check_manager() {
    if ! docker info --format '{{.Swarm.ControlAvailable}}' | grep -q "true"; then
        echo -e "${RED}Error: This command must be run on a Swarm manager node${NC}"
        exit 1
    fi
}

deploy_portainer() {
    echo -e "${BLUE}Deploying Portainer to Docker Swarm...${NC}"
    
    check_swarm
    check_manager
    
    if [ ! -f "$STACK_FILE" ]; then
        echo -e "${RED}Error: Stack file $STACK_FILE not found${NC}"
        exit 1
    fi
    
    # Create data directory if it doesn't exist
    sudo mkdir -p /data/portainer
    sudo chown root:root /data/portainer
    
    # Deploy the stack
    docker stack deploy --compose-file "$STACK_FILE" "$STACK_NAME"
    
    echo -e "${GREEN}Portainer deployment initiated...${NC}"
    echo -e "${YELLOW}Waiting for service to be ready...${NC}"
    
    # Wait for service to be ready
    local timeout=300  # 30 iterations * 10 seconds
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if docker service ls --filter name=${STACK_NAME}_portainer --format '{{.Replicas}}' | grep -q "1/1"; then
            echo -e "${GREEN}✅ Portainer is ready!${NC}"
            break
        fi
        echo -n "."
        sleep 10
        elapsed=$((elapsed + 10))
    done
    
    # Get manager node IP
    MANAGER_IP=$(docker node ls --filter role=manager --format '{{.Hostname}}' | head -1 | xargs -I {} docker node inspect {} --format '{{.Status.Addr}}')
    
    echo ""
    echo -e "${GREEN}🎉 Portainer deployed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Access URLs:${NC}"
    echo -e "  HTTPS: https://${MANAGER_IP}:9443"
    echo -e "  HTTP:  http://${MANAGER_IP}:9000"
    echo ""
    echo -e "${YELLOW}First-time setup:${NC}"
    echo "1. Navigate to https://${MANAGER_IP}:9443"
    echo "2. Accept the certificate warning"
    echo "3. Create your admin account"
    echo "4. Select 'Docker Swarm' environment"
    echo "5. Portainer will auto-detect your cluster"
}

show_status() {
    echo -e "${BLUE}Portainer Cluster Status:${NC}"
    
    check_swarm
    
    if docker stack ls --format '{{.Name}}' | grep -q "^${STACK_NAME}$"; then
        echo -e "${GREEN}✅ Portainer stack is deployed${NC}"
        echo ""
        
        echo -e "${BLUE}Services:${NC}"
        docker service ls --filter name=${STACK_NAME} --format 'table {{.Name}}\t{{.Mode}}\t{{.Replicas}}\t{{.Image}}\t{{.Ports}}'
        
        echo ""
        echo -e "${BLUE}Cluster Nodes:${NC}"
        docker node ls --format 'table {{.Hostname}}\t{{.Status}}\t{{.Availability}}\t{{.ManagerStatus}}'
        
        # Get manager node IP for URLs
        MANAGER_IP=$(docker node ls --filter role=manager --format '{{.Hostname}}' | head -1 | xargs -I {} docker node inspect {} --format '{{.Status.Addr}}')
        
        echo ""
        echo -e "${BLUE}Access URLs:${NC}"
        echo -e "  HTTPS: https://${MANAGER_IP}:9443"
        echo -e "  HTTP:  http://${MANAGER_IP}:9000"
        
        echo ""
        echo -e "${BLUE}Agent Status:${NC}"
        AGENT_COUNT=$(docker service ls --filter name=${STACK_NAME}_portainer_agent --format '{{.Replicas}}' | head -1)
        if [ -n "$AGENT_COUNT" ]; then
            echo -e "  Agents: ${GREEN}${AGENT_COUNT} deployed${NC}"
        else
            echo -e "  Agents: ${YELLOW}Not deployed${NC}"
        fi
    else
        echo -e "${RED}❌ Portainer stack is not deployed${NC}"
    fi
}

show_logs() {
    echo -e "${BLUE}Portainer Service Logs:${NC}"
    
    check_swarm
    
    if docker stack ls --format '{{.Name}}' | grep -q "^${STACK_NAME}$"; then
        docker service logs ${STACK_NAME}_portainer --tail 50 --follow
    else
        echo -e "${RED}❌ Portainer stack is not deployed${NC}"
        exit 1
    fi
}

remove_portainer() {
    echo -e "${YELLOW}Removing Portainer from Docker Swarm...${NC}"
    
    check_swarm
    check_manager
    
    if docker stack ls --format '{{.Name}}' | grep -q "^${STACK_NAME}$"; then
        docker stack rm "$STACK_NAME"
        echo -e "${GREEN}✅ Portainer removal initiated...${NC}"
        echo -e "${YELLOW}Waiting for cleanup to complete...${NC}"
        
        # Wait for stack to be completely removed
        while docker stack ls --format '{{.Name}}' | grep -q "^${STACK_NAME}$"; do
            echo -n "."
            sleep 5
        done
        
        echo ""
        echo -e "${GREEN}✅ Portainer removed successfully${NC}"
        echo -e "${YELLOW}Note: Data directory /data/portainer preserved${NC}"
    else
        echo -e "${YELLOW}⚠️  Portainer stack is not currently deployed${NC}"
    fi
}

update_portainer() {
    echo -e "${BLUE}Updating Portainer to latest version...${NC}"
    
    check_swarm
    check_manager
    
    if docker stack ls --format '{{.Name}}' | grep -q "^${STACK_NAME}$"; then
        echo -e "${YELLOW}Pulling latest Portainer image...${NC}"
        docker service update --image portainer/portainer-ce:latest ${STACK_NAME}_portainer
        echo -e "${GREEN}✅ Portainer update initiated${NC}"
        echo -e "${YELLOW}Monitor with: docker service logs ${STACK_NAME}_portainer${NC}"
    else
        echo -e "${RED}❌ Portainer stack is not deployed${NC}"
        echo "Deploy first with: $0 deploy"
        exit 1
    fi
}

case "${1:-help}" in
    deploy)
        deploy_portainer
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    remove)
        remove_portainer
        ;;
    update)
        update_portainer
        ;;
    help|*)
        print_usage
        ;;
esac
