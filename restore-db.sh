#!/bin/bash
# Restore your database from 
# Usage: ./backup-db.sh [SUFFIX]

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

. "$SCRIPT_DIR"/docker.env
export COMPOSE_FILE="$SCRIPT_DIR"/docker-compose.yml

SUFFIX="${1:-latest}"

docker run --rm -i --env-file "$SCRIPT_DIR"/docker.env amazon/aws-cli \
    ${S3_ENDPOINT:+--endpoint-url "${S3_ENDPOINT}"} \
    s3 cp "${BACKUP_OBJECT_S3URL}${SUFFIX}" - \
    | \
docker compose exec -T db pg_restore -d misskey --clean
