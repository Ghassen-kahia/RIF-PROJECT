#!/bin/bash
set -euo pipefail

# --- Configuration ---
BACKUP_DIR="/backup"
LOG_FILE="/var/log/backup.log"
DB_CONTAINER="apps-db-1"
ODOO_CONTAINER="apps-odoo-1"
POSTGRES_USER="odoo"
DB_NAME="odoo"   # base réellement utilisée par Odoo, pas POSTGRES_DB du .env

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
WORKDIR=$(mktemp -d)

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log "=== Début du backup ==="

# 1. Dump PostgreSQL (sans arrêter les conteneurs)
log "Dump de la base ${DB_NAME} via docker exec..."
docker exec "$DB_CONTAINER" pg_dump -U "$POSTGRES_USER" "$DB_NAME" > "$WORKDIR/db_dump.sql"
log "Dump terminé : $(du -h "$WORKDIR/db_dump.sql" | cut -f1)"

# 2. Copie du filestore Odoo
log "Copie du filestore Odoo..."
docker cp "$ODOO_CONTAINER":/var/lib/odoo "$WORKDIR/odoo-filestore"
log "Filestore copié"

# 3. Archive finale (dump + filestore ensemble)
log "Création de l'archive ${ARCHIVE_NAME}..."
tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$WORKDIR" db_dump.sql odoo-filestore
log "Archive créée : $BACKUP_DIR/$ARCHIVE_NAME ($(du -h "$BACKUP_DIR/$ARCHIVE_NAME" | cut -f1))"

rm -rf "$WORKDIR"
log "=== Backup terminé avec succès ==="
