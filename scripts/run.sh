#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 1 ]; then
  echo "Usage: bash scripts/run.sh path/to/file.cypher" >&2
  exit 2
fi
file="$1"
if [ ! -f "$file" ]; then
  echo "File not found: $file" >&2
  exit 2
fi
docker compose up -d >/dev/null
ready=0
for attempt in $(seq 1 45); do
  if docker compose exec -T neo4j cypher-shell -u neo4j -p classroom123 "RETURN 1 AS ok;" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done
if [ "$ready" != 1 ]; then
  echo "Neo4j not ready; check: docker compose logs --tail=80 neo4j" >&2
  exit 1
fi
echo "Executing $file"
docker compose exec -T neo4j cypher-shell -u neo4j -p classroom123 < "$file"
