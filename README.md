# Advanced Databases — Neo4j and Cypher

A GitHub Codespaces classroom lab for **CSCI 480 / CIS 680**. Practice graph data models, traversals, and Cypher queries with a sample university database.

## Start

**Recommended graphical interface:** [Browser-based Cypher Practice](docs/cypher-practice.md). Open port **8501** from Codespaces to write Cypher and visualize graphs without connecting your local browser directly to Neo4j Bolt.

For an existing Codespace, run `git pull` and `docker compose up -d --build` first.


1. On GitHub, select **Code → Codespaces → Create codespace on main**.
2. Codespaces starts Neo4j using Docker Compose. The first launch downloads the container image.
3. When Codespaces starts, a popup should offer to open **Cypher Practice** in your browser. Click **Open in Browser**. The application runs on port **8501**; you do not need to select the port manually. If you dismiss the popup, open **Ports → 8501 → Open in Browser** later. The sample graph may not be loaded yet.
4. In the Codespaces terminal, load the sample dataset once:

~~~bash
bash scripts/run.sh examples/01_setup.cypher
~~~

   The script creates four Student nodes, three Course nodes, and six ENROLLED_IN relationships. If the sample data is already present, you normally do not need to run it again. To check service status, optionally run `docker compose ps`.
5. Return to port **8501**, run a Cypher query, and select **Graph** to visualize results. Optionally run `bash scripts/run.sh examples/02_queries.cypher` in the terminal to see prepared examples.
6. Work through [student exercises](exercises/README.md) and write your queries in a copy of [student_template.cypher](exercises/student_template.cypher).

If Neo4j is not running, use `docker compose up -d`. The run script waits for Neo4j to be ready.

## Graph model

- `(:Student {id, name})` and `(:Course {code, title})` nodes
- `(:Student)-[:ENROLLED_IN]->(:Course)` relationships
- Four students, three courses, and six relationships
- Uniqueness constraints on student IDs and course codes

A first query:

~~~cypher
MATCH (s:Student)-[:ENROLLED_IN]->(c:Course {code: 'CSCI 480'})
RETURN s.name AS student
ORDER BY student;
~~~

This is similar to joining the Student, Enrollment, and Course tables in SQL, but expresses the relationship pattern directly.

## Run queries in the terminal

~~~bash
bash scripts/run.sh examples/01_setup.cypher
bash scripts/run.sh examples/02_queries.cypher
bash scripts/check.sh
~~~

Run a single query:

~~~bash
docker compose exec -T neo4j cypher-shell -u neo4j -p classroom123 "MATCH (n) RETURN count(n) AS nodes;"
~~~

## Optional: Official Neo4j Browser

**Use Cypher Practice on port 8501 for classroom exercises.** It connects to Neo4j internally, so students do not need to configure external Bolt access or open ports 7474/7687.

Neo4j also offers its official Browser interface on port **7474**, using Bolt on port **7687**. In browser-based GitHub Codespaces, that connection can fail because of forwarded-port authentication and WebSocket restrictions, even when the Browser page loads. For advanced use only, see [Neo4j Browser connection instructions](docs/neo4j-browser-codespaces.md). Keep forwarded ports **Private**.

## Repository contents

| Path | Purpose |
| --- | --- |
| `.devcontainer/devcontainer.json` | Configures Codespaces and Docker |
| `compose.yaml` | Neo4j Community service and persistent volume |
| `examples/01_setup.cypher` | Repeatable sample university graph |
| `examples/02_queries.cypher` | Seven read-query examples |
| `exercises/README.md` | Eight student assignments |
| `exercises/student_template.cypher` | Blank student answer file |
| `instructor/solutions.cypher` | Instructor reference answers |
| `scripts/run.sh` | Run a Cypher file |
| `scripts/check.sh` | Test the database connection |
| `scripts/reset.sh` | Destructive reset of example data |

## Instructor / security notes

**Instructor answers are visible to everyone who can read this repository.** If students will receive access, make a separate student-facing copy **without** the `instructor/` directory. A private GitHub repository does not hide selected files from collaborators.

The password `classroom123` is for classroom practice only. Leave Codespaces port visibility **Private** and never use this password in production.

Each Codespace has its own data volume. `docker compose down` stops Neo4j without deleting data; `docker compose down -v` **deletes** its database volume. To start the example over, explicitly run `bash scripts/reset.sh --yes`; this deletes every graph node/relationship in that Codespace's Neo4j database.

## References

- [Cypher manual](https://neo4j.com/docs/cypher-manual/current/)
- [Neo4j Docker documentation](https://neo4j.com/docs/operations-manual/current/docker/)
- [Codespaces port forwarding](https://docs.github.com/en/codespaces/developing-in-a-codespace/forwarding-ports-in-your-codespace)
