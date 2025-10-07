#!/bin/bash
#
# MySQL Data Archiver Script using Percona pt-archiver
# Author: Puneet Kumar
# Date: 2025-10-05
#

# ========== CONFIGURATION ==========
SOURCE_HOST="localhost"
SOURCE_DB="salesdb"
SOURCE_TABLE="orders"

DEST_HOST="localhost"
DEST_DB="salesdb"
DEST_TABLE="orders_archive"

MYSQL_USER="root"
MYSQL_PASS="yourpassword"

# Archive condition: rows older than 6 months
ARCHIVE_CONDITION="order_date < NOW() - INTERVAL 6 MONTH"

# Batch size (how many rows to process per iteration)
LIMIT=1000

# Log file location
LOG_FILE="/var/log/pt-archiver-$(date +%F).log"

# ========== SAFETY CHECKS ==========
echo "🔍 Checking Percona Toolkit installation..."
if ! command -v pt-archiver &> /dev/null; then
  echo "❌ Error: pt-archiver not found. Please install Percona Toolkit first."
  echo "   On Ubuntu: sudo apt install percona-toolkit"
  echo "   On Amazon Linux: sudo yum install percona-toolkit"
  exit 1
fi

echo "🔍 Checking MySQL connection..."
mysql -h "$SOURCE_HOST" -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SELECT 1;" >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Error: Unable to connect to MySQL. Please check credentials."
  exit 1
fi

# ========== ARCHIVING PROCESS ==========
echo "✅ Starting archiving process for $SOURCE_DB.$SOURCE_TABLE"
echo "   Condition: $ARCHIVE_CONDITION"
echo "   Logging to: $LOG_FILE"
echo "-----------------------------------------------"

# Dry-run preview
echo "🧪 Performing dry-run..."
pt-archiver \
  --source "h=$SOURCE_HOST,D=$SOURCE_DB,t=$SOURCE_TABLE,u=$MYSQL_USER,p=$MYSQL_PASS" \
  --dest "h=$DEST_HOST,D=$DEST_DB,t=$DEST_TABLE,u=$MYSQL_USER,p=$MYSQL_PASS" \
  --where "$ARCHI




🧩 How to Use

Save script:


sudo nano /usr/local/bin/mysql_archive.sh

Make it executable:

sudo chmod +x /usr/local/bin/mysql_archive.sh


Run manually:

sudo /usr/local/bin/mysql_archive.sh


crontab -e

Add:

0 2 * * * /usr/local/bin/mysql_archive.sh >> /var/log/mysql_archive_cron.log 2>&1
