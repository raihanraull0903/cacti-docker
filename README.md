<div align="center">

# 🐳 Cacti Docker

### Production-ready Dockerized Cacti Monitoring Stack

A lightweight and easy-to-deploy **Cacti 1.2.31** environment running on **Docker**, complete with **Apache**, **PHP 8.3**, **MariaDB**, **SNMP**, and automatic initialization.

![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)
![PHP](https://img.shields.io/badge/PHP-8.3-777BB4?logo=php)
![Apache](https://img.shields.io/badge/Apache-2.4-D22128?logo=apache)
![MariaDB](https://img.shields.io/badge/MariaDB-10.11-003545?logo=mariadb)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

# 📖 Overview

This project provides a fully Dockerized deployment of **Cacti**, an enterprise-grade network monitoring solution.

Instead of manually installing Apache, PHP, MariaDB, SNMP, RRDtool, and configuring everything yourself, simply clone the repository and start the containers.

The initialization process automatically:

- Creates the Cacti configuration
- Waits for the database to become available
- Imports the Cacti database schema
- Imports the official Cacti templates
- Sets the required permissions
- Starts Apache automatically

---

# ✨ Features

- Dockerized Cacti 1.2.31
- PHP 8.3
- Apache Web Server
- MariaDB Database
- Automatic Database Initialization
- Automatic Configuration Generation
- Automatic Official Template Import
- SNMP Ready
- RRDtool Included
- Healthcheck Support
- Easy Deployment using Docker Compose

# 🧰 Tech Stack

| Component | Version |
|-----------|----------|
| Cacti | 1.2.31 |
| PHP | 8.3 |
| Apache | 2.4 |
| MariaDB | 10.11 |
| Docker | Latest |
| Docker Compose | v2 |
| SNMP | Included |
| RRDtool | Included |

---

# 📁 Project Structure

```text
cacti-docker/
│
├── Dockerfile
├── docker-compose.yml
├── LICENSE
├── README.md
│
├── config/
│   ├── apache.conf
│   └── php.ini
│
├── docker/
│   └── entrypoint.sh
│
├── scripts/
│   ├── init-cacti.sh
│   └── wait-for-db.sh
│
├── sql/
├── docs/
└── screenshots/
```

---

# 🚀 Quick Start

Clone the repository

```bash
git clone git@github.com:raihanraull0903/cacti-docker.git

cd cacti-docker
```

Create the environment file

```bash
cp .env.example .env
```

Start the application

```bash
docker compose up -d
```

Open your browser

```
http://YOUR_SERVER_IP
```

---

# ⚙ Environment Variables

Example configuration

```env
MYSQL_DATABASE=cacti

MYSQL_USER=cactiuser

MYSQL_PASSWORD=Cacti123!

MYSQL_ROOT_PASSWORD=Root123!

TZ=Asia/Jakarta
```

---

# 🏗 Architecture

```text
               Browser
                  │
                  ▼
          Apache + PHP 8.3
                  │
                  ▼
            Cacti Application
                  │
        ┌─────────┴─────────┐
        ▼                   ▼
     MariaDB            RRDtool
```

---

# 📦 Automatic Installation

When the container starts, the initialization script automatically:

- Waits for MariaDB
- Creates `config.php`
- Configures the database connection
- Imports the Cacti database
- Imports the official templates
- Sets file permissions
- Starts Apache

No manual installation is required.

---

# 🛠 Requirements

- Docker Engine
- Docker Compose
- Linux Server
- 2 GB RAM (minimum)

---

# 📚 Documentation

Additional documentation will be available in the `docs/` directory.

---

# 🐳 Docker Hub

Docker Hub image will be published soon.

---

# 🛣 Roadmap

- [ ] Publish Docker image to Docker Hub
- [ ] GitHub Actions (CI/CD)
- [ ] HTTPS Support
- [ ] Persistent Volumes
- [ ] Automated Backup
- [ ] Multi-Architecture Images
- [ ] Production Deployment Guide

---

# 🤝 Contributing

Contributions are welcome.

If you have suggestions or improvements, feel free to open an Issue or submit a Pull Request.

---

# 📄 License

This project is licensed under the MIT License.

---

# 👨‍💻 Author

**Raihan Raul**

GitHub: https://github.com/raihanraull0903

---

<div align="center">

⭐ If this project helps you, please consider giving it a star!
  
</div>
