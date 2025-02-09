#!/bin/bash
# Restore your database from 
# Usage: ./backup-db.sh [SUFFIX]

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml
. "$SCRIPT_DIR"/../etc/docker.env

SUFFIX="${1:-latest}"

docker run --rm -i --env-file "$SCRIPT_DIR"/../etc/docker.env amazon/aws-cli:2.22.35 \
    ${S3_ENDPOINT:+--endpoint-url "${S3_ENDPOINT}"} \
    s3 cp "${BACKUP_OBJECT_S3URL}${SUFFIX+_${SUFFIX}}" - \
    | \
docker compose exec -T db pg_restore -d misskey --clean
