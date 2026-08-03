# =====================================================
# Cacti Docker Image
# Base Image
# =====================================================
FROM php:8.3-apache

LABEL maintainer="Raihan"
LABEL application="Cacti"

ENV DEBIAN_FRONTEND=noninteractive

# =====================================================
# Install Linux Packages
# =====================================================
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    cron \
    snmp \
    snmpd \
    libsnmp-dev \
    gettext \
    rrdtool \
    mariadb-client \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libicu-dev \
    libldap2-dev \
    libgmp-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libonig-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*
# =====================================================
# PHP Extensions
# =====================================================
RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        pdo \
        pdo_mysql \
        gd \
        intl \
        gmp \
        ldap \
        zip \
        bcmath \
        gettext \
        sockets \
        pcntl

RUN mkdir -p /tmp/php-sessions \
    && chown www-data:www-data /tmp/php-sessions \
    && chmod 770 /tmp/php-sessions


# =====================================================
# Apache Module
# =====================================================
RUN a2enmod rewrite headers expires

# =====================================================
# Download & Install Cacti
# =====================================================

WORKDIR /tmp

ARG CACTI_VERSION=1.2.31

RUN wget https://files.cacti.net/cacti/linux/cacti-${CACTI_VERSION}.tar.gz \
    && tar -xzf cacti-${CACTI_VERSION}.tar.gz \
    && rm cacti-${CACTI_VERSION}.tar.gz \
    && mv cacti-${CACTI_VERSION} /var/www/html/cacti

# =====================================================
# Permission
# =====================================================

RUN chown -R www-data:www-data /var/www/html/cacti \
    && chmod -R 755 /var/www/html/cacti


# =====================================================
# Copy Configuration
# =====================================================

COPY config/apache.conf /etc/apache2/sites-available/000-default.conf
COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY scripts /scripts

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && chmod +x /scripts/*.sh

WORKDIR /var/www/html/cacti

HEALTHCHECK CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["entrypoint.sh"]
