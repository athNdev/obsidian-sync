# Self-Hosted Obsidian Sync with Tailscale

A Docker-based solution for syncing Obsidian vaults across devices using CouchDB (with Obsidian-LiveSync plugin) and Tailscale for secure networking.

## Features

- **Self-hosted sync**: Full control over your data using CouchDB
- **Secure access**: All traffic routed through Tailscale VPN
- **Automated backups**: Daily backups with 2-backup rotation
- **Pre-configured CORS**: Ready for Obsidian-LiveSync plugin
- **Persistent data**: All volumes stored on host

## Prerequisites

- Docker & Docker Compose installed
- Tailscale account (free tier works)
- At least 2GB RAM and 10GB disk space

## Setup Instructions

### 1. Generate Tailscale Auth Key

1. Go to [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
2. Click "Generate auth key"
3. Recommended settings:
   - **Reusable**: Yes (allows container restarts)
   - **Ephemeral**: No (keeps device in network)
   - **Tags**: `tag:container` (optional, for ACL management)
4. Copy the generated key (starts with `tskey-auth-`)

### 2. Configure Environment Variables

```bash
# Copy the example file
cp .env.example .env

# Edit .env with your values
# Windows: notepad .env
# Linux/Mac: nano .env
```

Update the following:
- `TS_AUTHKEY`: Paste your Tailscale auth key
- `COUCHDB_USER`: Set admin username (default: admin)
- `COUCHDB_PASSWORD`: **Change to a strong password (20+ characters)**

### 3. Start Services

```bash
# Start all services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

### 4. Verify Tailscale Connection

```bash
# Check Tailscale status
docker exec obsidian-tailscale tailscale status

# Get your Tailscale hostname
docker exec obsidian-tailscale tailscale ip -4
```

Your CouchDB will be accessible at: `http://<tailscale-hostname>:5984`

### 5. Access CouchDB Admin UI (Fauxton)

From any device on your Tailscale network:

1. Navigate to `http://<tailscale-hostname>:5984/_utils`
2. Login with your `COUCHDB_USER` and `COUCHDB_PASSWORD`
3. Create a new database (e.g., `obsidian` or `my-vault`)

### 6. Configure Obsidian-LiveSync Plugin

On each device with Obsidian:

1. Install "Self-hosted LiveSync" plugin from Community Plugins
2. Open plugin settings
3. Configure remote database:
   - **Database URL**: `http://<tailscale-hostname>:5984`
   - **Database name**: Name you created in step 5
   - **Username**: Your `COUCHDB_USER`
   - **Password**: Your `COUCHDB_PASSWORD`
4. Enable "End-to-End Encryption" (recommended)
5. Click "Test Database Connection"
6. If successful, enable sync

## Data Persistence

All data is persisted in the following locations:

- **CouchDB data**: `couchdb-data` Docker volume
- **CouchDB config**: `couchdb-config` Docker volume
- **Tailscale state**: `tailscale-data` Docker volume
- **Backups**: `./backups/` directory (host filesystem)

### Backup Schedule

- Automated daily backups at **00:00 (midnight)**
- Keeps **2 most recent backups**
- Location: `./backups/couchdb-backup-YYYYMMDD_HHMMSS.tar.gz`

### Manual Backup

```bash
# Trigger backup immediately
docker exec obsidian-backup /backup.sh

# List backups
ls -lh ./backups/
```

### Restore from Backup

```bash
# Stop CouchDB
docker compose stop couchdb

# Extract backup
docker run --rm \
  -v obsidian_sync_couchdb-data:/data \
  -v $(pwd)/backups:/backups \
  alpine:latest \
  sh -c "cd /data && rm -rf * && tar -xzf /backups/couchdb-backup-YYYYMMDD_HHMMSS.tar.gz"

# Start CouchDB
docker compose start couchdb
```

## Maintenance

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f couchdb
docker compose logs -f tailscale
docker compose logs -f backup
```

### Update Services

```bash
# Pull latest images
docker compose pull

# Recreate containers
docker compose up -d
```

### Stop Services

```bash
# Stop all
docker compose down

# Stop and remove volumes (WARNING: deletes data)
docker compose down -v
```

## Troubleshooting

### CouchDB not accessible

1. Check Tailscale is connected: `docker exec obsidian-tailscale tailscale status`
2. Verify CouchDB is running: `docker compose ps`
3. Check logs: `docker compose logs couchdb`

### Obsidian-LiveSync connection fails

1. Verify database URL uses Tailscale hostname (not `localhost`)
2. Ensure device is connected to Tailscale network
3. Test direct access: `curl http://<tailscale-hostname>:5984` (should return CouchDB version)
4. Check CORS configuration in Fauxton UI

### Backup not running

1. Check backup container: `docker compose logs backup`
2. Manually trigger: `docker exec obsidian-backup /backup.sh`
3. Verify `./backups/` directory exists and is writable

## Security Notes

- Never expose CouchDB port (5984) to the public internet
- Access is restricted to your Tailscale network only
- Use strong passwords (20+ characters, mixed case, numbers, symbols)
- Consider enabling Tailscale ACLs to restrict access further
- Backups are stored unencrypted - secure the host filesystem appropriately

## Resources

- [Obsidian-LiveSync Plugin](https://github.com/vrtmrz/obsidian-livesync)
- [CouchDB Documentation](https://docs.couchdb.org/)
- [Tailscale Documentation](https://tailscale.com/kb/)
