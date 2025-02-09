#!/bin/bash
# Post a note from Ai-chan
# Usage: ./note-ai.sh [TAG]

set -euC
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml

. ${SCRIPT_DIR}/../etc/docker.env

ESCAPED="${1//\\/\\\\}"
ESCAPED="${1//\"/\\\"}"

docker compose exec lb \
  curl http://0.0.0.0/api/notes/create \
  --request POST --header 'Content-Type: application/json' \
  -d "{\"text\":\"${ESCAPED}\",\"poll\":null,\"cw\":null,\"localOnly\":false,\"visibility\":\"public\",\"i\":\"${AI_MISSKEY_TOKEN}\"}"