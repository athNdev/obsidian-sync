#!/bin/bash
# CouchDB CORS Setup Script
# Run this after CouchDB container starts to configure CORS for Obsidian-LiveSync

COUCHDB_URL="${COUCHDB_URL}"
COUCHDB_USER="${COUCHDB_USER:-admin}"
COUCHDB_PASSWORD="${COUCHDB_PASSWORD}"

echo "Configuring CouchDB CORS settings for Obsidian-LiveSync..."

# Enable CORS
curl -X PUT "${COUCHDB_URL}/_node/_local/_config/chttpd/enable_cors" \
  -H "Content-Type: application/json" \
  -d '"true"' \
  --user "${COUCHDB_USER}:${COUCHDB_PASSWORD}"

curl -X PUT "${COUCHDB_URL}/_node/_local/_config/httpd/enable_cors" \
  -H "Content-Type: application/json" \
  -d '"true"' \
  --user "${COUCHDB_USER}:${COUCHDB_PASSWORD}"

# Configure CORS origins
curl -X PUT "${COUCHDB_URL}/_node/_local/_config/cors/origins" \
  -H "Content-Type: application/json" \
  -d '"app://obsidian.md,capacitor://localhost,http://localhost"' \
  --user "${COUCHDB_USER}:${COUCHDB_PASSWORD}"

# Configure CORS credentials
curl -X PUT "${COUCHDB_URL}/_node/_local/_config/cors/credentials" \
  -H "Content-Type: application/json" \
  -d '"true"' \
  --user "${COUCHDB_USER}:${COUCHDB_PASSWORD}"

# Configure CORS headers
curl -X PUT "${COUCHDB_URL}/_node/_local/_config/cors/headers" \
  -H "Content-Type: application/json" \
  -d '"accept, authorization, content-type, origin, referer"' \
  --user "${COUCHDB_USER}:${COUCHDB_PASSWORD}"

# Configure CORS methods
curl -X PUT "${COUCHDB_URL}/_node/_local/_config/cors/methods" \
  -H "Content-Type: application/json" \
  -d '"GET, PUT, POST, HEAD, DELETE"' \
  --user "${COUCHDB_USER}:${COUCHDB_PASSWORD}"

# Set max document size
curl -X PUT "${COUCHDB_URL}/_node/_local/_config/couchdb/max_document_size" \
  -H "Content-Type: application/json" \
  -d '"50000000"' \
  --user "${COUCHDB_USER}:${COUCHDB_PASSWORD}"

# Set max HTTP request size  
curl -X PUT "${COUCHDB_URL}/_node/_local/_config/chttpd/max_http_request_size" \
  -H "Content-Type: application/json" \
  -d '"4294967296"' \
  --user "${COUCHDB_USER}:${COUCHDB_PASSWORD}"

echo ""
echo "CORS configuration complete!"
echo "CouchDB is ready for Obsidian-LiveSync"
