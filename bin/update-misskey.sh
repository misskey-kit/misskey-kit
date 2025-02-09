#!/bin/bash
# Update misskey container from dockerhub without downtime
# Usage: ./update-misskey.sh [TAG]

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml

TAG="${1:-latest}"

docker container prune -f
docker image prune -f

if [[ "$TAG" == "latest" ]]; then
    docker pull misskey/misskey:latest
elif [[ "$TAG" =~ / ]]; then
    # PATH/IMAGE:TAG format
    docker pull "$TAG"
    docker tag "$TAG" misskey/misskey:latest
else
    # TAG format
    docker pull misskey/misskey:"$TAG"
    docker tag misskey/misskey:"$TAG" misskey/misskey:latest
fi

OLD_CONTAINER="$(docker compose ps web | tail -n1 | awk '{print $1}')"
docker compose up -d --no-recreate --wait --scale web=2 web
docker stop "$OLD_CONTAINER"
docker container prune -f
docker image prune -f
