#!/bin/bash
# pitr_one_table.sh
# Point-in-Time Recovery for one MySQL table

DB_NAME="testing_db"
TABLE_NAME="orders"
BINLOG_PATH="/var/lib/mysql"
STOP_TIME="2025-10-05 14:10:00"
MYSQL_USER="root"
MYSQL_PASS="YourPassword"

echo "=== Starting PITR for ${DB_NAME}.${TABLE_NAME} ==="

# Step 1: Backup current table
echo "[1/4] Taking backup of current table..."
mysqldump -u$MYSQL_USER -p$MYSQL_PASS $DB_NAME $TABLE_NAME > ${TABLE_NAME}_pre_restore.sql

# Step 2: Restore from last good backup
echo "[2/4] Restoring from last good backup..."
mysql -u$MYSQL_USER -p$MYSQL_PASS $DB_NAME < /backups/${TABLE_NAME}_full_backup.sql

# Step 3: Extract binary logs up to STOP_TIME
echo "[3/4] Extracting binlogs until $STOP_TIME..."
mysqlbinlog --stop-datetime="$STOP_TIME" $BINLOG_PATH/mysql-bin.* > ${TABLE_NAME}_pitr.sql

# Step 4: Apply binlogs to table
echo "[4/4] Applying extracted transactions..."
mysql -u$MYSQL_USER -p$MYSQL_PASS $DB_NAME < ${TABLE_NAME}_pitr.sql

echo "=== PITR Completed Successfully for ${DB_NAME}.${TABLE_NAME} ==="
