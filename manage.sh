#!/bin/bash

# Docker Stack Management Script
set -e

COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="development-stack"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}    Development Stack Manager   ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi

    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
}

start_stack() {
    print_status "Starting development stack..."

    # Stop existing containers if running
    sudo docker stop $(sudo docker ps -q) 2>/dev/null || true

    # Start with docker-compose
    sudo docker compose up -d

    print_status "Stack started successfully!"
    print_status "Services available at:"
    echo "  - Portainer: https://localhost:9443 (admin/admin123)"
    echo "  - Grafana: http://localhost:3000 (admin/admin123)"
    echo "  - Kibana: http://localhost:5601"
    echo "  - Prometheus: http://localhost:9090"
    echo "  - Elasticsearch: http://localhost:9200"
    echo "  - PostgreSQL: localhost:5432 (admin/admin123)"
    echo "  - Redis: localhost:6379"
    echo "  - MongoDB: localhost:27017 (admin/admin123)"
}

stop_stack() {
    print_status "Stopping development stack..."
    sudo docker compose down
    print_status "Stack stopped successfully!"
}

restart_stack() {
    print_status "Restarting development stack..."
    sudo docker compose restart
    print_status "Stack restarted successfully!"
}

show_status() {
    print_status "Current stack status:"
    sudo docker compose ps
}

show_logs() {
    if [ -n "$2" ]; then
        print_status "Showing logs for service: $2"
        sudo docker compose logs -f "$2"
    else
        print_status "Showing logs for all services:"
        sudo docker compose logs -f
    fi
}

backup_data() {
    print_status "Creating backup..."
    BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p $BACKUP_DIR

    # Backup PostgreSQL
    sudo docker exec postgres-main pg_dump -U admin maindb > $BACKUP_DIR/postgres_backup.sql

    # Backup MongoDB
    sudo docker exec mongodb-server mongodump --host localhost --port 27017 --username admin --password admin123 --authenticationDatabase admin --out $BACKUP_DIR/mongodb_backup

    print_status "Backup created in: $BACKUP_DIR"
}

show_help() {
    print_header
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  start     Start the development stack"
    echo "  stop      Stop the development stack"
    echo "  restart   Restart the development stack"
    echo "  status    Show current status of all services"
    echo "  logs      Show logs for all services"
    echo "  logs <service>  Show logs for specific service"
    echo "  backup    Backup databases"
    echo "  help      Show this help message"
    echo
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs grafana"
    echo "  $0 backup"
    echo
}

# Main script logic
case "${1:-help}" in
    start)
        print_header
        check_requirements
        start_stack
        ;;
    stop)
        print_header
        stop_stack
        ;;
    restart)
        print_header
        restart_stack
        ;;
    status)
        print_header
        show_status
        ;;
    logs)
        show_logs "$@"
        ;;
    backup)
        print_header
        backup_data
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
