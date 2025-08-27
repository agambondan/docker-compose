# 🚀 Fullstack Development Guide

Panduan lengkap untuk menggunakan development environment ini untuk fullstack development dengan Next.js, React, PHP, Node.js, Java, dan Go.

## 📊 Data ke Elasticsearch - 3 Cara

### 1. Direct API ke Elasticsearch
```bash
# Test direct ke Elasticsearch
curl -X POST "http://localhost:9200/app-logs/_doc" \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
    "level": "INFO",
    "message": "Test log message",
    "service": "my-app",
    "environment": "development"
  }'
```

### 2. Via Logstash (Recommended)
```bash
# Test kirim ke Logstash HTTP input
curl -X POST "http://localhost:8080" \
  -H "Content-Type: application/json" \
  -d '{
    "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
    "level": "INFO", 
    "message": "Test via Logstash",
    "service": "my-app"
  }'

# Test kirim ke Logstash TCP input
echo '{"level":"INFO","message":"TCP test","service":"my-app"}' | nc localhost 5000
```

### 3. Via Filebeat (Otomatis untuk Docker logs)
Filebeat sudah dikonfigurasi untuk mengambil logs dari semua Docker containers dan mengirimkannya ke Logstash.

## 🛠️ Development Environments

### Node.js & Next.js Development

```bash
# Start Node.js container
sudo docker compose up -d node-dev

# Access container
sudo docker exec -it node-development sh

# Dalam container
cd /app
npm create next-app@latest . --typescript --tailwind --eslint
npm run dev
```

**URL**: http://localhost:3001

**Contoh logging ke Elasticsearch dari Node.js**:
```javascript
const axios = require('axios');

async function logToElasticsearch(data) {
  try {
    await axios.post('http://elasticsearch-master:9200/app-logs/_doc', {
      timestamp: new Date().toISOString(),
      level: 'INFO',
      message: data.message,
      service: 'nextjs-app',
      environment: 'development',
      ...data
    });
    console.log('Logged to Elasticsearch');
  } catch (error) {
    console.error('Failed to log to Elasticsearch:', error);
  }
}

// Usage
logToElasticsearch({ message: 'User logged in', userId: 123 });
```

### PHP Development

```bash
# Start PHP services
sudo docker compose up -d php-dev nginx-dev

# Access PHP container
sudo docker exec -it php-development sh
```

**URL**: http://localhost:8080

File PHP sudah tersedia di `projects/php/index.php` dengan contoh:
- Database connections (PostgreSQL, MongoDB, Redis)
- Send logs to Elasticsearch & Logstash
- Testing interface

### Java Development

```bash
# Start Java container
sudo docker compose up -d java-dev

# Access container  
sudo docker exec -it java-development bash

# Dalam container - buat Spring Boot project
curl https://start.spring.io/starter.tgz \
  -d dependencies=web,jpa,postgresql,data-redis \
  -d type=maven-project \
  -d javaVersion=17 \
  -d bootVersion=3.1.0 \
  -d groupId=com.example \
  -d artifactId=demo | tar -xzf - --strip=1

# Build dan run
./mvnw spring-boot:run
```

**URL**: http://localhost:8081
**Debug Port**: 5005

### Go Development

```bash
# Start Go container
sudo docker compose up -d golang-dev

# Access container
sudo docker exec -it go-development sh

# Dalam container
go mod init my-app
go get github.com/gin-gonic/gin
go get github.com/elastic/go-elasticsearch/v8
```

**URL**: http://localhost:8082
**Debug Port**: 2345 (untuk Delve debugger)

File Go sudah tersedia di `projects/go/main.go` dengan:
- REST API endpoints
- Elasticsearch logging functions
- Health check endpoints

## 🗄️ Development Tools

### MinIO (S3-compatible Storage)

```bash
# Access MinIO console
# URL: http://localhost:9001
# User: admin
# Pass: admin123

# Buat bucket via CLI
sudo docker exec minio-storage mc alias set local http://localhost:9000 admin admin123
sudo docker exec minio-storage mc mb local/my-bucket
```

**API Endpoint**: http://localhost:9000
**Console**: http://localhost:9001

### SonarQube (Code Quality)

```bash
# First time setup - create sonarqube database
sudo docker exec postgres-main createdb -U admin sonarqube

# Access SonarQube
# URL: http://localhost:9002
# Default: admin/admin (change on first login)
```

### Jenkins (CI/CD)

```bash
# Get initial admin password
sudo docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword

# Access Jenkins
# URL: http://localhost:8083
```

## 📈 Monitoring & Logging

### Grafana Dashboards
- **URL**: http://localhost:3000
- **Login**: admin/admin123

Import pre-built dashboards:
1. Node Exporter Full (ID: 1860)
2. Docker Container Metrics (ID: 193)
3. Elasticsearch Metrics (ID: 6483)

### Kibana Log Analysis
- **URL**: http://localhost:5601

Setup index patterns:
1. `logstash-*` - untuk logs dari Logstash
2. `filebeat-*` - untuk Docker container logs

### Prometheus Metrics
- **URL**: http://localhost:9090

Available metrics endpoints:
- Node metrics: `up{job="node-exporter"}`
- Elasticsearch: `up{job="elasticsearch"}`

## 🔗 Service Connections

### Database Connections dari Applications

**PostgreSQL**:
```
Host: postgres-main
Port: 5432  
Database: maindb
Username: admin
Password: admin123
```

**MongoDB**:
```
Connection String: mongodb://admin:admin123@mongodb-server:27017/maindb
```

**Redis**:
```  
Host: redis-main
Port: 6379
No password (atau uncomment di redis.conf)
```

### Elasticsearch dari Applications

**Direct Connection**:
```
Host: elasticsearch-master
Port: 9200
No authentication
```

**Via Logstash** (Recommended):
```
HTTP: http://logstash-server:8080
TCP: logstash-server:5000
Beats: logstash-server:5044
```

## 📝 Best Practices

### 1. Logging Strategy
```
Application Logs → Logstash → Elasticsearch → Kibana
                ↓
            (Processing, filtering, enrichment)
```

### 2. Development Workflow
1. Code dalam `projects/[language]/` folder
2. Container auto-reload pada file changes  
3. Logs otomatis masuk ke Elasticsearch
4. Monitor via Grafana dashboards
5. Debug via Kibana

### 3. Database Strategy
- **PostgreSQL**: Relational data, transactions
- **MongoDB**: Document data, flexibility  
- **Redis**: Cache, sessions, real-time data

### 4. Storage Strategy
- **MinIO**: File uploads, media storage
- **Docker Volumes**: Persistent data

## 🧪 Testing & Debugging

### Health Checks
```bash
# Check all services
curl http://localhost:8082/health  # Go service
curl http://localhost:8080         # PHP service  
curl http://localhost:3001         # Node.js service
curl http://localhost:9200/_cluster/health  # Elasticsearch
```

### Log Testing
```bash
# Send test logs
curl -X POST http://localhost:8082/test-elasticsearch
curl -X POST http://localhost:8082/test-logstash
curl -X POST http://localhost:8080  # PHP test buttons
```

### Performance Testing  
```bash
# Load test dengan Apache Bench
sudo apt install apache2-utils
ab -n 1000 -c 10 http://localhost:8082/health
```

## 🚀 Production Readiness

### Security Checklist
- [ ] Change all default passwords
- [ ] Enable authentication untuk Elasticsearch
- [ ] Setup SSL certificates
- [ ] Configure firewall rules
- [ ] Setup backup strategy
- [ ] Monitor resource usage

### Performance Optimization
- [ ] Tune Elasticsearch JVM settings
- [ ] Configure PostgreSQL for production
- [ ] Setup Redis persistence
- [ ] Configure Nginx caching
- [ ] Setup log rotation

### Scaling Strategy
- [ ] Horizontal scaling untuk apps
- [ ] Elasticsearch cluster scaling  
- [ ] Database read replicas
- [ ] Load balancer configuration
- [ ] Container orchestration (K8s)

## 📚 Resources & Documentation

- [Elasticsearch Guide](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Logstash Configuration](https://www.elastic.co/guide/en/logstash/current/configuration.html)
- [Next.js Documentation](https://nextjs.org/docs)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Gin Gonic (Go) Documentation](https://gin-gonic.com/docs/)

---

**Happy Coding! 🎉**
