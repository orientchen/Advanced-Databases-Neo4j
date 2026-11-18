#!/usr/bin/env bash
set -euo pipefail
docker compose ps
docker compose exec -T neo4j cypher-shell -u neo4j -p classroom123 "RETURN 'Neo4j ready' AS status;"
