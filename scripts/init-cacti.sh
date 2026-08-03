#!/bin/bash

set -ex

echo "========================================"
echo "      Cacti Initialization"
echo "========================================"

echo "Waiting MariaDB..."

/scripts/wait-for-db.sh

echo "MariaDB is Ready."

# ---------------------------------------------------
# Create config.php if it doesn't exist
# ---------------------------------------------------

if [ ! -f /var/www/html/cacti/include/config.php ]; then
    cp /var/www/html/cacti/include/config.php.dist \
       /var/www/html/cacti/include/config.php
fi

# ---------------------------------------------------
# Configure Database
# ---------------------------------------------------

sed -i "s/\$database_type *=.*/\$database_type = 'mysql';/" \
/var/www/html/cacti/include/config.php

sed -i "s/\$database_default *=.*/\$database_default = '${MYSQL_DATABASE}';/" \
/var/www/html/cacti/include/config.php

sed -i "s/\$database_hostname *=.*/\$database_hostname = 'mariadb';/" \
/var/www/html/cacti/include/config.php

sed -i "s/\$database_username *=.*/\$database_username = '${MYSQL_USER}';/" \
/var/www/html/cacti/include/config.php

sed -i "s/\$database_password *=.*/\$database_password = '${MYSQL_PASSWORD}';/" \
/var/www/html/cacti/include/config.php

sed -i "s/\$database_port *=.*/\$database_port = '3306';/" \
/var/www/html/cacti/include/config.php

sed -i "s#\$url_path *=.*#\$url_path = '/';#" \
/var/www/html/cacti/include/config.php

sed -i "s/\$cacti_session_name *=.*/\$cacti_session_name = 'Cacti';/" \
/var/www/html/cacti/include/config.php

# ---------------------------------------------------
# Check database
# ---------------------------------------------------
TABLES=$(mysql \
--skip-ssl \
-h mariadb \
--user="${MYSQL_USER}" \
--password="${MYSQL_PASSWORD}" \
--database="${MYSQL_DATABASE}" \
-Nse "SHOW TABLES;" | wc -l)

if [ "$TABLES" = "0" ]; then

    echo "Importing Cacti Database..."
mysql \
--skip-ssl \
-h mariadb \
--user="${MYSQL_USER}" \
--password="${MYSQL_PASSWORD}" \
--database="${MYSQL_DATABASE}" \
< /var/www/html/cacti/cacti.sql

    echo "Database Imported."

else

    echo "Database already initialized."

fi

# ---------------------------------------------------
# Permission
# ---------------------------------------------------

chown -R www-data:www-data /var/www/html/cacti

chmod -R 755 /var/www/html/cacti

echo "Initialization Complete."
