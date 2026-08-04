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

sed -i "s/\$database_type *=.*/\$database_type = 'mysql';/" /var/www/html/cacti/include/config.php
sed -i "s/\$database_default *=.*/\$database_default = '${MYSQL_DATABASE}';/" /var/www/html/cacti/include/config.php
sed -i "s/\$database_hostname *=.*/\$database_hostname = 'mariadb';/" /var/www/html/cacti/include/config.php
sed -i "s/\$database_username *=.*/\$database_username = '${MYSQL_USER}';/" /var/www/html/cacti/include/config.php
sed -i "s/\$database_password *=.*/\$database_password = '${MYSQL_PASSWORD}';/" /var/www/html/cacti/include/config.php
sed -i "s/\$database_port *=.*/\$database_port = '3306';/" /var/www/html/cacti/include/config.php
sed -i "s#\$url_path *=.*#\$url_path = '/';#" /var/www/html/cacti/include/config.php
sed -i "s/\$cacti_session_name *=.*/\$cacti_session_name = 'Cacti';/" /var/www/html/cacti/include/config.php

# --- BYPASS INSTALLER WIZARD DI CONFIG ---
if ! grep -q "cacti_installed" /var/www/html/cacti/include/config.php; then
    echo "\$cacti_installed = true;" >> /var/www/html/cacti/include/config.php
fi

# ---------------------------------------------------
# Check database
# ---------------------------------------------------
TABLES=$(mysql --skip-ssl -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" -Nse "SHOW TABLES;" 2>/dev/null | wc -l)

if [ "$TABLES" = "0" ]; then
    echo "Importing Cacti Database..."
    mysql --skip-ssl -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" < /var/www/html/cacti/cacti.sql
    echo "Database Imported successfully."
fi

# ---------------------------------------------------
# FORCE FULL VERSION FLAGS & DEFAULT ADMIN ACCOUNT
# ---------------------------------------------------
echo "Injecting version flags and setting up full admin account..."
mysql --skip-ssl -h mariadb -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" "${MYSQL_DATABASE}" <<EOF
DELETE FROM version;
INSERT INTO version (cacti) VALUES ('1.2.31');
INSERT INTO settings (name, value) VALUES ('cacti_version', '1.2.31') ON DUPLICATE KEY UPDATE value='1.2.31';
INSERT INTO settings (name, value) VALUES ('install_complete', '1') ON DUPLICATE KEY UPDATE value='1';
INSERT INTO settings (name, value) VALUES ('auth_method', '1') ON DUPLICATE KEY UPDATE value='1';
UPDATE settings SET value = '0' WHERE name IN ('guest_user', 'user_template', 'autologin_user');
EOF

echo "Setting up clean default admin user (admin/admin)..."
php -r "
require_once('/var/www/html/cacti/include/global.php');

// Clear old admin user entries
db_execute('DELETE FROM user_auth WHERE username = \"admin\" OR id = 1');
db_execute('DELETE FROM user_auth_realm WHERE user_id = 1');

// Bcrypt Hash for password 'admin'
\$hash = password_hash('admin', PASSWORD_BCRYPT);

// Re-create complete admin account
db_execute_prepared('INSERT INTO user_auth (
    id, username, password, realm, full_name, must_change_password, 
    password_change, show_tree, show_list, show_preview, login_opts, 
    policy_graphs, policy_trees, policy_hosts, policy_graph_templates, enabled, locked, failed_attempts
) VALUES (
    1, \"admin\", ?, 0, \"Administrator\", \"on\", \"on\", \"on\", \"on\", \"on\", 
    1, 1, 1, 1, 1, \"on\", \"\", 0
)', array(\$hash));

db_execute('UPDATE user_auth SET enabled = \"on\" WHERE id = 1');

// Inject ALL Realm IDs (1-150) so Console, Graphs, Reporting, Logs tabs work
for (\$i = 1; \$i <= 150; \$i++) {
    db_execute_prepared('INSERT IGNORE INTO user_auth_realm (realm_id, user_id) VALUES (?, 1)', array(\$i));
}

db_execute('TRUNCATE TABLE sessions');
" || true

# =====================================================
# Auto-Import Seluruh Package XML Cacti
# =====================================================
echo "==> Meng-import ulang seluruh Package XML bawaan Cacti..."

# Gunakan flag --remove-orphans agar Cacti melakukan commit/import nyata ke database
find /var/www/html/cacti/install/templates/ -type f \( -name "*.xml" -o -name "*.gz" \) | while read -r pkg; do
    echo "Importing package: $pkg"
    php /var/www/html/cacti/cli/import_package.php --filename="$pkg" --remove-orphans || true
done

# Sync/Refresh cache template di database
php /var/www/html/cacti/cli/repair_templates.php --execute || true

echo "==> Import Package XML Cacti Selesai 100%!"

# ---------------------------------------------------
# Permission
# ---------------------------------------------------

chown -R www-data:www-data /var/www/html/cacti

chmod -R 755 /var/www/html/cacti

echo "Initialization Complete."


