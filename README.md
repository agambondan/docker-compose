# Fullstack Development Environment dengan Docker Compose

Repositori ini berisi konfigurasi lengkap untuk fullstack development environment menggunakan Docker Compose yang mencakup database, monitoring, logging, development tools, dan CI/CD.

```
docker network create --driver bridge --subnet 10.250.0.0/16 --gateway 10.250.0.1 shared_compose_net
```

## 🏗️ Arsitektur Stack

### Database Services
****
* **PostgreSQL 16** - Main database (Port: 5432)
* **Redis 7** - Cache & session store (Port: 6379)
* **MongoDB 7** - Document database (Port: 27017)

### Elasticsearch Stack (ELK)
****
* **Elasticsearch Cluster** - Search engine dengan master dan data nodes

  * Master Node (Port: 9200, 9300)
  * Data Node 1
  * Data Node 2
* **Logstash** - Log processing pipeline (Port: 5044, 5000, 9600)
* **Filebeat** - Log shipper untuk Docker containers
* **Kibana** - Data visualization (Port: 5601)

### Development Environments

* **Node.js 20** - Next.js & React development (Port: 3001)
* **PHP 8.2-FPM** - PHP development dengan Nginx (Port: 8080)
* **Java 17 JDK** - Java development dengan Maven (Port: 8081)
* **Go 1.21** - Go development environment (Port: 8082)

### Development Tools & CI/CD

* **MinIO** - S3-compatible object storage (Port: 9000, 9001)
* **SonarQube** - Code quality analysis (Port: 9002)
* **Jenkins** - CI/CD automation (Port: 8083)

### Monitoring Stack

* **Prometheus** - Metrics collection (Port: 9090)
* **Grafana** - Monitoring dashboard (Port: 3000)
* **Node Exporter** - System metrics (Port: 9100)

### Infrastructure

* **Nginx** - Reverse proxy (Port: 80, 443)
* **Portainer** - Docker management UI (Port: 8000, 9443)

---

## 🚀 Quick Start

### Menggunakan Management Script

```bash
# Start semua services
./manage.sh start

# Stop semua services
./manage.sh stop

# Restart service tertentu
./manage.sh restart grafana

# Check status
./manage.sh status
./manage.sh status postgres-main

# View logs
./manage.sh logs
./manage.sh logs grafana

# Backup databases
./manage.sh backup

# Lihat daftar service & grup
./manage.sh list
```

### Jalankan berdasarkan grup

Script mendukung grouping, jadi bisa start/stop per kategori:

```bash
./manage.sh start db         # Postgres, Mongo, Redis
./manage.sh start elastic    # Elasticsearch cluster
./manage.sh start kibana     # Kibana saja
./manage.sh start monitoring # Prometheus, Grafana, Node Exporter
./manage.sh start dev        # Semua environment dev (Node, PHP, Java, Go)
./manage.sh stop dev         # Stop semua service dev
```

**Grup yang tersedia:**

| Group        | Services                                                       |
| ------------ | -------------------------------------------------------------- |
| `db`         | postgres-main, mongodb, redis-main                             |
| `elastic`    | elasticsearch-master, elasticsearch-data1, elasticsearch-data2 |
| `kibana`     | kibana                                                         |
| `monitoring` | prometheus, node-exporter, grafana                             |
| `proxy`      | nginx                                                          |
| `elk-ingest` | logstash, filebeat                                             |
| `dev`        | node-dev, php-dev, nginx-dev, java-dev, golang-dev             |
| `tools`      | minio, sonarqube, jenkins                                      |

---

### Manual dengan Docker Compose

```bash
# Start stack
docker compose up -d

# Stop stack
docker compose down

# View status
docker compose ps

# View logs
docker compose logs -f [service_name]
```

---

## 📋 Default Credentials

| Service    | Username | Password | URL                                              |
| ---------- | -------- | -------- | ------------------------------------------------ |
| Portainer  | admin    | admin123 | [https://localhost:9443](https://localhost:9443) |
| Grafana    | admin    | admin123 | [http://localhost:3000](http://localhost:3000)   |
| PostgreSQL | admin    | admin123 | localhost:5432                                   |
| MongoDB    | admin    | admin123 | localhost:27017                                  |
| Kibana     | -        | -        | [http://localhost:5601](http://localhost:5601)   |
| Prometheus | -        | -        | [http://localhost:9090](http://localhost:9090)   |

---

## 🌐 URLs & Endpoints

### Web Interfaces

* **Portainer**: [https://localhost:9443](https://localhost:9443)
* **Grafana**: [http://localhost:3000](http://localhost:3000)
* **Kibana**: [http://localhost:5601](http://localhost:5601)
* **Prometheus**: [http://localhost:9090](http://localhost:9090)
* **Elasticsearch**: [http://localhost:9200](http://localhost:9200)

### Database Connections

* **PostgreSQL**: `postgresql://admin:admin123@localhost:5432/maindb`
* **Redis**: `redis://localhost:6379`
* **MongoDB**: `mongodb://admin:admin123@localhost:27017/maindb`

### Reverse Proxy (Nginx)

* **Grafana**: [http://grafana.local](http://grafana.local) (add to /etc/hosts)
* **Kibana**: [http://kibana.local](http://kibana.local) (add to /etc/hosts)
* **Portainer**: [http://portainer.local](http://portainer.local) (add to /etc/hosts)

---

## 📁 Struktur Folder

```
docker-compose/
├── docker-compose.yml          # Main compose file
├── manage.sh                   # Management script
├── README.md                   # This file
├── nginx/                      # Nginx configurations
│   ├── nginx.conf
│   └── conf.d/
├── grafana/                    # Grafana configurations
│   └── provisioning/
├── prometheus/                 # Prometheus configurations
│   ├── prometheus.yml
│   └── rules/
├── mongodb/                    # MongoDB init scripts
│   └── init/
├── elasticsearch/              # Elasticsearch configs
├── kibana/                     # Kibana configs
├── postgres/                   # PostgreSQL configs
├── redis/                      # Redis configs
└── portainer/                  # Portainer configs
```

---

## 🔧 Konfigurasi

### Networks

* `app_network` - Database services
* `elastic_network` - Elasticsearch cluster
* `monitoring_network` - Monitoring stack
* `proxy_network` - Reverse proxy

### Volumes

Semua data disimpan dalam Docker volumes:

* `postgres_data` - PostgreSQL data
* `redis_data` - Redis data
* `mongodb_data` - MongoDB data
* `elasticsearch_master_data` - ES master data
* `elasticsearch_data1` - ES data node 1
* `elasticsearch_data2` - ES data node 2
* `grafana_data` - Grafana dashboards
* `prometheus_data` - Prometheus metrics
* `kibana_data` - Kibana configs
* `portainer_data` - Portainer settings

---

## 🛠️ Customization

### Environment Variables

Sesuaikan environment variables di `docker-compose.yml`:

```yaml
environment:
  - POSTGRES_PASSWORD=your_password
  - GRAFANA_ADMIN_PASSWORD=your_password
```

### Resource Limits

Sesuaikan resource limits untuk production:

```yaml
deploy:
  resources:
    limits:
      memory: 1G
      cpus: '0.5'
```

### SSL/HTTPS

Untuk HTTPS, tambahkan SSL certificates di `nginx/ssl/` dan update konfigurasi nginx.

---

## 📊 Monitoring

### Grafana Dashboards

* Node Exporter metrics untuk system monitoring
* Docker containers monitoring
* Database performance metrics

### Prometheus Targets

* Node Exporter (system metrics)
* Grafana (application metrics)
* Elasticsearch (cluster health)

### Kibana

* Elasticsearch cluster monitoring
* Application logs analysis
* Custom dashboards

---

## 🔄 Backup & Recovery

### Manual Backup

```bash
# PostgreSQL
docker exec postgres-main pg_dump -U admin maindb > postgres_backup.sql

# MongoDB
docker exec mongodb-server mongodump --out /backup

# Redis
docker exec redis-main redis-cli BGSAVE
```

### Automated Backup

Gunakan script `manage.sh backup` untuk backup otomatis semua databases.

---

## 🐛 Troubleshooting

### Check Logs

```bash
# All services
docker compose logs

# Specific service
docker compose logs elasticsearch-master

# Follow logs
docker compose logs -f grafana
```

### Health Checks

```bash
# PostgreSQL
docker exec postgres-main pg_isready

# Redis
docker exec redis-main redis-cli ping

# MongoDB
docker exec mongodb-server mongosh --eval "db.runCommand('ping')"

# Elasticsearch
curl http://localhost:9200/_cluster/health
```

### Resource Issues

* Elasticsearch membutuhkan minimal 1GB RAM per node
* Sesuaikan `ES_JAVA_OPTS` jika memory terbatas
* Gunakan `docker stats` untuk monitoring resource usage

---

## 🔒 Security Notes

* **Production**: Ganti semua default passwords
* **Firewall**: Restrict ports access sesuai kebutuhan
* **SSL**: Enable HTTPS untuk semua web interfaces
* **Network**: Gunakan custom networks untuk isolation
* **Secrets**: Gunakan Docker secrets untuk production

---

## 📝 Changelog

* **v1.0** - Initial setup dengan complete development stack
* **v1.1** - Tambahan fitur management script:

  * Start/stop per service
  * Start/stop berdasarkan grup (db, elastic, kibana, monitoring, dev, tools, dll)
  * Command `list` untuk lihat semua service & grup

---

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Update configurations
4. Test with `./manage.sh start`
5. Submit pull request

---

## 📜 License

MIT License - feel free to use dan modify sesuai kebutuhan.

---
