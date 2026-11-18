#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 1 ] || [ "$1" != "--yes" ]; then
  echo "WARNING: deletes all graph nodes and relationships."
  echo "Confirm with: bash scripts/reset.sh --yes"
  exit 2
fi
docker compose exec -T neo4j cypher-shell -u neo4j -p classroom123 "MATCH (n) DETACH DELETE n;"
bash scripts/run.sh examples/01_setup.cypher
echo "Example graph reset."
