#!/bin/sh
# CouchDB Backup Script with 2-backup rotation
# Runs daily via cron to backup CouchDB data volume

BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="couchdb-backup-${DATE}.tar.gz"

echo "[$(date)] Starting CouchDB backup..."

# Create backup
if tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" -C /source .; then
    echo "[$(date)] Backup created: ${BACKUP_FILE}"
    
    # Rotation: Keep only 2 most recent backups
    cd "${BACKUP_DIR}" || exit 1
    BACKUP_COUNT=$(ls -1 couchdb-backup-*.tar.gz 2>/dev/null | wc -l)
    
    if [ "$BACKUP_COUNT" -gt 2 ]; then
        ls -t couchdb-backup-*.tar.gz | tail -n +3 | xargs rm -f
        echo "[$(date)] Old backups removed, keeping 2 most recent"
    fi
    
    echo "[$(date)] Backup completed successfully"
else
    echo "[$(date)] ERROR: Backup failed!"
    exit 1
fi
