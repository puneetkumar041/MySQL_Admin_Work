#####-- Script: sync_binlogs_rsync.sh


#!/bin/bash

# CONFIGURATION
BINLOG_DIR="/var/lib/mysql"
REMOTE_USER="remote_user"
REMOTE_HOST="192.168.1.100"
REMOTE_DIR="/backup/mysql/binlogs"
ARCHIVE_DIR="/var/lib/mysql/compressed_binlogs"
LOG_TRACK="/var/log/binlog_copy.log"
RETENTION_DAYS=7

# Ensure archive directory exists
mkdir -p "$ARCHIVE_DIR"

# Go to binlog directory
cd "$BINLOG_DIR" || exit 1

# Find all mysql-bin.* files except index
for BINLOG in mysql-bin.*; do
    [[ "$BINLOG" == "mysql-bin.index" ]] && continue

    # Compress if not already compressed
    if [ ! -f "$ARCHIVE_DIR/$BINLOG.gz" ]; then
        echo "$(date): Compressing $BINLOG..." >> "$LOG_TRACK"
        gzip -c "$BINLOG" > "$ARCHIVE_DIR/$BINLOG.gz"
    fi
done

# Rsync compressed binlogs
echo "$(date): Syncing compressed binlogs to $REMOTE_HOST..." >> "$LOG_TRACK"

### scp "$ARCHIVE_DIR" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"

rsync -av --ignore-existing "$ARCHIVE_DIR/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/" >> "$LOG_TRACK" 2>&1

# Optional: Delete compressed files older than RETENTION_DAYS
find "$ARCHIVE_DIR" -name "*.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

echo "$(date): Binlog sync completed." >> "$LOG_TRACK"



##### Cron Job (Every 15 Minutes)
crontab -e
*/15 * * * * /path/to/sync_binlogs_rsync.sh

##### On Remote Server

mkdir -p /backup/mysql/binlogs
chown remote_user:remote_user /backup/mysql/binlogs

