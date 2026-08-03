# Cacti Docker

Docker image untuk menjalankan Cacti 1.2.31 menggunakan PHP 8.3 + Apache + MariaDB.

## Features

- PHP 8.3
- Apache 2
- MariaDB Support
- SNMP
- RRDTool
- Auto Initialization
- Docker Compose Ready

## Requirements

- Docker Engine 24+
- Docker Compose

## Quick Start

Clone repository

```bash
git clone https://github.com/USERNAME/cacti-docker.git
cd cacti-docker
```

Copy environment

```bash
cp .env.example .env
```

Run

```bash
docker compose up -d
```

Open browser

```
http://localhost
```

Default Login

```
Username: admin
Password: admin
```

## Folder Structure

```
config/
docker/
scripts/
Dockerfile
docker-compose.yml
```

## License

MIT
