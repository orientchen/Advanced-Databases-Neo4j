# Browser-based Cypher Practice

This repository provides a small classroom Cypher interface that works inside GitHub Codespaces **without a browser-to-Bolt connection**.

## First use in an existing Codespace

Pull the latest repository changes:

```bash
git pull
docker compose up -d --build
```

Open the **Ports** tab and find **8501 — Cypher Practice**. Keep visibility **Private** and choose **Open in Browser**. You can also run `curl http://localhost:8501/health` from the Codespaces terminal to check the service.

If you have not loaded the sample graph, run this **once**:

```bash
bash scripts/run.sh examples/01_setup.cypher
```

Now use the web page to type and execute Cypher directly. Select an example from the dropdown or type your own query. Graph visualization works when your query returns node/relationship/path values:

```cypher
MATCH (s:Student)-[r:ENROLLED_IN]->(c:Course)
RETURN s, r, c;
```

If you only return scalar properties (for example `RETURN s.name`), the results appear as a table.

## How it works

```text
Local Chrome browser
   | HTTPS (GitHub Codespaces private port 8501)
   v
Flask Cypher Practice web app (in Codespace)
   | bolt://neo4j:7687 (internal Docker network)
   v
Neo4j database (in Codespace)
```

This is a **simple teaching interface**, not the official Neo4j Browser. It supports one Cypher statement at a time and shows at most 200 records. It executes write queries too, so students can create nodes and relationships. It is intended for a private, individual Codespace and must not be exposed as a public service.

If you receive an error, inspect `docker compose logs --tail=80 cypher-practice`.

## Known limitations

- Graph layout is a simple circle, not a physics-based graph editor.
- No advanced Neo4j Browser features such as query plans, multi-statement scripts, or result exports.
- The demo database password is intentionally fixed for classroom use. Never use this configuration for production.
