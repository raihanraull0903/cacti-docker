#!/bin/bash

set -e

echo "Waiting for MariaDB..."

until mysql \
    --skip-ssl \
    -h mariadb \
    -u"${MYSQL_USER}" \
    -p"${MYSQL_PASSWORD}" \
    -e "SELECT 1;" >/dev/null 2>&1
do
    echo "Waiting for MariaDB..."
    sleep 3
done

echo "MariaDB Ready."
