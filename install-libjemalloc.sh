#!/bin/bash
# Fetch libjemalloc.so.2 from misskey/misskey:latest and put it into misskey-lib64/

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

. "$SCRIPT_DIR"/docker.env
export COMPOSE_FILE="$SCRIPT_DIR"/docker-compose.yml

docker run --rm -u root -v misskey-lib64:/misskey-lib64 misskey/misskey:latest bash -c \
    "apt update -y && apt install -y libjemalloc-dev && cp /usr/lib/x86_64-linux-gnu/libjemalloc.so.2 /misskey-lib64"
