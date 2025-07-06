#!/bin/bash

# Set your new root password here
NEW_PASSWORD="YourNewStrongPassword123!"

echo "Stopping MySQL/MySQL service..."
sudo service mysql stop 2>/dev/null || sudo service MySQL stop

echo "Starting MySQL in skip-grant-tables mode..."
sudo mysqld_safe --skip-grant-tables &
sleep 8  # Give time for server to boot

echo "Resetting root password..."
mysql -u root <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${NEW_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "Shutting down MySQL..."
mysqladmin -u root -p"${NEW_PASSWORD}" shutdown

echo "Restarting MySQL service..."
sudo service mysql start 2>/dev/null || sudo service MySQL start

echo "✅ Root password reset and privilege system re-enabled."




🔐 How to Use:
Save as: mysql_reset_privileges.sh

Make it executable:

chmod +x mysql_reset_privileges.sh

./mysql_reset_privileges.sh

