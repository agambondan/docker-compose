#!/usr/bin/env bash
# Docker Stack Management Script

set -euo pipefail

COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="development-stack"

# ---------- Colors ----------
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

print_status()  { echo -e "${GREEN}[INFO]${NC} $*"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------- Docker runner (auto sudo bila perlu) ----------
_docker() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo docker "$@"
  else
    print_error "Tidak bisa mengakses Docker daemon (butuh izin atau sudo)."
    exit 1
  fi
}
COMPOSE() { _docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" "$@"; }

check_requirements() {
  if ! command -v docker >/dev/null 2>&1; then
    print_error "Docker is not installed"
    exit 1
  fi
  if ! _docker compose version >/dev/null 2>&1; then
    print_error "Docker Compose is not installed"
    exit 1
  fi
  if [[ ! -f "$COMPOSE_FILE" ]]; then
    print_error "File '$COMPOSE_FILE' tidak ditemukan"
    exit 1
  fi
}

start_stack() {
  print_status "Starting development stack..."

  # (Opsional) Stop semua container yang sedang berjalan di host
  # Komentar baris berikut jika tidak ingin stop container lain di luar project ini
  _docker stop "$(_docker ps -q)" 2>/dev/null || true

  COMPOSE up -d

  print_status "Stack started successfully!"
  print_status "Services available at:"
  echo "  - Portainer:    https://localhost:9443 (admin/admin123)"
  echo "  - Grafana:      http://localhost:3000 (admin/admin123)"
  echo "  - Kibana:       http://localhost:5601"
  echo "  - Prometheus:   http://localhost:9090"
  echo "  - Elasticsearch http://localhost:9200"
  echo "  - PostgreSQL:   localhost:5432 (admin/admin123)"
  echo "  - Redis:        localhost:6379"
  echo "  - MongoDB:      localhost:27017 (admin/admin123)"
}

stop_stack() {
  print_status "Stopping development stack..."
  COMPOSE down
  print_status "Stack stopped successfully!"
}

restart_stack() {
  print_status "Restarting development stack..."
  COMPOSE restart
  print_status "Stack restarted successfully!"
}

show_status() {
  print_status "Current stack status:"
  COMPOSE ps
}

show_logs() {
  if [[ $# -ge 1 && -n "${1:-}" ]]; then
    local svc="$1"
    print_status "Showing logs for service: $svc"
    COMPOSE logs -f "$svc"
  else
    print_status "Showing logs for all services:"
    COMPOSE logs -f
  fi
}

backup_data() {
  print_status "Creating backup..."
  local BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$BACKUP_DIR"

  # PostgreSQL
  if _docker ps --format '{{.Names}}' | grep -qx 'postgres-main'; then
    _docker exec postgres-main pg_dump -U admin maindb > "$BACKUP_DIR/postgres_backup.sql" \
      || print_warning "PostgreSQL backup failed"
  else
    print_warning "postgres-main not running; skipping PostgreSQL backup"
  fi

  # MongoDB
  if _docker ps --format '{{.Names}}' | grep -qx 'mongodb-server'; then
    _docker exec mongodb-server mongodump \
      --host localhost --port 27017 \
      --username admin --password admin123 \
      --authenticationDatabase admin \
      --out "/tmp/mongodb_backup" \
      || print_warning "MongoDB backup failed"
    # copy hasil dump ke host
    _docker cp mongodb-server:/tmp/mongodb_backup "$BACKUP_DIR/mongodb_backup" || true
  else
    print_warning "mongodb-server not running; skipping MongoDB backup"
  fi

  print_status "Backup created in: $BACKUP_DIR"
}

show_help() {
  print_header
  cat <<EOF
Usage: $0 <command> [args]

Commands:
  start              Start the development stack
  stop               Stop the development stack
  restart            Restart the development stack
  status             Show current status of all services
  logs               Show logs for all services
  logs <service>     Show logs for specific service
  backup             Backup databases
  help               Show this help message

Examples:
  $0 start
  $0 logs grafana
  $0 backup
EOF
}

# ---------- Main ----------
main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    start)
      print_header
      check_requirements
      start_stack
      ;;
    stop)
      print_header
      check_requirements
      stop_stack
      ;;
    restart)
      print_header
      check_requirements
      restart_stack
      ;;
    status)
      print_header
      check_requirements
      show_status
      ;;
    logs)
      check_requirements
      show_logs "${1:-}"
      ;;
    backup)
      print_header
      check_requirements
      backup_data
      ;;
    help|--help|-h)
      show_help
      ;;
    *)
      print_error "Unknown command: $cmd"
      show_help
      exit 1
      ;;
  esac
}

main "$@"
