#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="development-stack"

# ---------- Colors ----------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

print_header()  { echo -e "${BLUE}================================\n    Development Stack Manager   \n================================${NC}\n"; }
print_info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
print_warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
print_err()     { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------- Docker runner (auto sudo bila perlu) ----------
_docker() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo docker "$@"
  else
    print_err "Docker akses ditolak dan 'sudo' tidak tersedia."
    exit 1
  fi
}

COMPOSE() { _docker compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME" "$@"; }

check_requirements() {
  command -v docker >/dev/null || { print_err "Docker tidak terpasang"; exit 1; }
  _docker compose version >/dev/null || { print_err "Docker Compose tidak tersedia"; exit 1; }
  [[ -f "$COMPOSE_FILE" ]] || { print_err "File $COMPOSE_FILE tidak ditemukan"; exit 1; }
}

# ---------- Groups ----------
# Definisikan grup agar gampang start/stop by group
declare -A GROUPS=(
  [db]="postgres-main mongodb redis-main"
  [elastic]="elasticsearch-master elasticsearch-data1 elasticsearch-data2"
  [kibana]="kibana"
  [monitoring]="prometheus node-exporter grafana"
  [proxy]="nginx"
  [elk-ingest]="logstash filebeat"
  [dev]="node-dev php-dev nginx-dev java-dev golang-dev"
  [tools]="minio sonarqube jenkins"
)

# Ambil daftar service valid dari compose
services_all() {
  COMPOSE config --services
}

is_service() {
  services_all | grep -qx "$1"
}

expand_targets() {
  # Expand argumen: bisa berupa nama service atau nama grup
  local out=()
  if [[ $# -eq 0 ]]; then
    echo "" ; return 0
  fi
  for t in "$@"; do
    if [[ -n "${GROUPS[$t]:-}" ]]; then
      for s in ${GROUPS[$t]}; do out+=("$s"); done
    else
      if is_service "$t"; then
        out+=("$t")
      else
        print_warn "Target '$t' tidak dikenali (bukan service & bukan grup). Diabaikan."
      fi
    fi
  done
  # unik
  printf "%s\n" "${out[@]}" | awk '!x[$0]++'
}

start_all() {
  print_info "Menjalankan seluruh stack (semua service)…"
  COMPOSE up -d
  post_info
}

start_targets() {
  local targets=("$@")
  print_info "Menjalankan: ${targets[*]}"
  COMPOSE up -d "${targets[@]}"
  post_info
}

stop_all() {
  print_info "Menghentikan seluruh stack…"
  COMPOSE down
  print_info "Stack dihentikan."
}

stop_targets() {
  local targets=("$@")
  print_info "Stop: ${targets[*]}"
  COMPOSE stop "${targets[@]}"
  print_info "Stopped."
}

restart_targets() {
  local targets=("$@")
  print_info "Restart: ${targets[*]}"
  COMPOSE restart "${targets[@]}"
  print_info "Restarted."
}

status_cmd() {
  if [[ $# -gt 0 ]]; then
    COMPOSE ps "$@"
  else
    COMPOSE ps
  fi
}

logs_cmd() {
  if [[ $# -gt 0 ]]; then
    COMPOSE logs -f "$@"
  else
    COMPOSE logs -f
  fi
}

backup_data() {
  print_info "Membuat backup…"
  local BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$BACKUP_DIR"

  # Postgres
  if _docker ps --format '{{.Names}}' | grep -q '^postgres-main$'; then
    _docker exec postgres-main pg_dump -U admin maindb > "$BACKUP_DIR/postgres_backup.sql" || print_warn "Backup Postgres gagal"
  else
    print_warn "Container postgres-main tidak berjalan; skip backup Postgres."
  fi

  # Mongo
  if _docker ps --format '{{.Names}}' | grep -q '^mongodb-server$'; then
    _docker exec mongodb-server mongodump --host localhost --port 27017 \
      --username admin --password admin123 --authenticationDatabase admin \
      --out "$BACKUP_DIR/mongodb_backup" || print_warn "Backup Mongo gagal"
  else
    print_warn "Container mongodb-server tidak berjalan; skip backup Mongo."
  fi

  print_info "Backup tersimpan di: $BACKUP_DIR"
}

list_cmd() {
  echo -e "${BLUE}Services (compose)${NC}"
  services_all | sed 's/^/  - /'
  echo
  echo -e "${BLUE}Groups (shortcut)${NC}"
  for g in "${!GROUPS[@]}"; do
    printf "  - %s: %s\n" "$g" "${GROUPS[$g]}"
  done
}

post_info() {
  echo
  print_info "Endpoints (jika service aktif):"
  echo "  - Grafana:      http://localhost:3000 (admin/admin123)"
  echo "  - Kibana:       http://localhost:5601"
  echo "  - Prometheus:   http://localhost:9090"
  echo "  - Elasticsearch http://localhost:9200"
  echo "  - PostgreSQL:   localhost:5432 (admin/admin123)"
  echo "  - Redis:        localhost:6379"
  echo "  - MongoDB:      localhost:27017 (admin/admin123)"
}

usage() {
  print_header
  cat <<EOF
Usage:
  $0 start                # start semua service
  $0 start <svc|group>..  # start sebagian (service/grup)
  $0 stop                 # stop semua
  $0 stop <svc|group>..   # stop sebagian
  $0 restart <svc|group>..# restart sebagian
  $0 status [svc]         # status semua atau 1 service
  $0 logs [svc]           # logs semua atau 1 service
  $0 backup               # backup Postgres & Mongo
  $0 list                 # tampilkan services & groups
  $0 help                 # bantuan

Groups:
$(for g in "${!GROUPS[@]}"; do printf "  - %-11s %s\n" "$g" "${GROUPS[$g]}"; done)

Contoh:
  $0 start db
  $0 start elastic kibana
  $0 stop dev
  $0 restart nginx
  $0 logs grafana
  $0 status postgres-main
EOF
}

main() {
  local cmd="${1:-help}"; shift || true
  check_requirements

  case "$cmd" in
    start)
      print_header
      if [[ $# -eq 0 ]]; then start_all; else
        mapfile -t targets < <(expand_targets "$@")
        [[ ${#targets[@]} -gt 0 ]] || { print_err "Tidak ada target valid."; exit 1; }
        start_targets "${targets[@]}"
      fi
      ;;
    stop)
      print_header
      if [[ $# -eq 0 ]]; then stop_all; else
        mapfile -t targets < <(expand_targets "$@")
        [[ ${#targets[@]} -gt 0 ]] || { print_err "Tidak ada target valid."; exit 1; }
        stop_targets "${targets[@]}"
      fi
      ;;
    restart)
      print_header
      mapfile -t targets < <(expand_targets "$@")
      [[ ${#targets[@]} -gt 0 ]] || { print_err "Sebutkan service/grup yang ingin direstart."; exit 1; }
      restart_targets "${targets[@]}"
      ;;
    status)
      status_cmd "$@"
      ;;
    logs)
      logs_cmd "$@"
      ;;
    backup)
      print_header
      backup_data
      ;;
    list)
      list_cmd
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      print_err "Perintah tidak dikenali: $cmd"
      usage
      exit 1
      ;;
  esac
}

main "$@"
