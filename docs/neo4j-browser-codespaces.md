# Connecting Neo4j Browser in GitHub Codespaces

Neo4j Browser is the **web client** on port **7474**. The actual database connection uses the **Bolt** port **7687**. Both ports must be forwarded and remain **Private**.

## 1. Open the graphical client

In the Codespaces **Ports** tab, open the forwarded address for **7474** and append `/browser/` to the URL.

If the page loads but shows **Connect to instance**, the web server is working. You still need to tell Neo4j Browser where Bolt is.

## 2. Connect to the database

In the **Ports** tab, copy the **Forwarded Address** for **7687**, not 7474. For example:

```text
https://YOUR-CODESPACE-NAME-7687.app.github.dev
```

In the Neo4j Browser connection form:

1. Click the pencil/edit icon beside the displayed connection address, if necessary.
2. Choose **bolt+s** as the **Protocol** (TLS is terminated by the GitHub Codespaces HTTPS proxy).
3. For **Connection URL**, use only the hostname from the **7687** forwarded address, without `https://`, a trailing slash, or `/browser/`.
4. Database user: `neo4j`
5. Password: `classroom123`
6. Click **Connect**.

**Important:** GitHub's private forwarded-port authentication and WebSocket proxy behavior can prevent this connection from working in a web browser, even when both ports show green. This is not a Cypher error. The connection approach above is a suggested test, not a guaranteed workaround. Do **not** change the ports to Public to make it work.

## 3. Reliable alternative

The Codespaces terminal connects to the database inside Docker without any browser forwarding:

```bash
bash scripts/run.sh examples/01_setup.cypher
bash scripts/run.sh examples/02_queries.cypher
```

To enter an interactive Cypher shell:

```bash
docker compose exec neo4j cypher-shell -u neo4j -p classroom123
```

You can then type Cypher directly, for example:

```cypher
MATCH (n) RETURN count(n);
```

Type `:exit` to leave the shell.

## 4. Check server readiness

```bash
docker compose ps
curl -I http://localhost:7474/
docker compose logs --tail=30 neo4j
```

A local `HTTP/1.1 200 OK` confirms the HTTP service works **inside** Codespaces. It does not prove the external Bolt WebSocket connection will work.

## 5. Desktop alternative

If you open the Codespace in **VS Code Desktop**, both forwarded ports may be available locally. Open `http://localhost:7474/browser/` on your computer, then try the `bolt://localhost:7687` connection, user `neo4j`, password `classroom123`.
