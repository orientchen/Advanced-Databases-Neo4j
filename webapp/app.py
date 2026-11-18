import os
from flask import Flask, jsonify, render_template, request
from neo4j import GraphDatabase
from neo4j.graph import Node, Relationship, Path
from neo4j.time import Date, DateTime, Time, Duration

app = Flask(__name__)
driver = GraphDatabase.driver(
    os.getenv("NEO4J_URI", "bolt://neo4j:7687"),
    auth=(os.getenv("NEO4J_USER", "neo4j"), os.getenv("NEO4J_PASSWORD", "classroom123")),
    connection_timeout=8,
)

def convert(value):
    if isinstance(value, Node):
        return {"labels": list(value.labels), "properties": dict(value)}
    if isinstance(value, Relationship):
        return {"type": value.type, "properties": dict(value)}
    if isinstance(value, Path):
        return {"nodes": [convert(n) for n in value.nodes],
                "relationships": [convert(r) for r in value.relationships]}
    if isinstance(value, (Date, DateTime, Time, Duration)):
        return str(value)
    if isinstance(value, dict):
        return {str(k): convert(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        return [convert(v) for v in value]
    if isinstance(value, (str, int, float, bool)) or value is None:
        return value
    return str(value)

def graph_from(value, nodes, edges):
    if isinstance(value, Node):
        key = str(value.element_id)
        nodes[key] = {"id": key, "labels": sorted(value.labels), "properties": convert(dict(value))}
    elif isinstance(value, Relationship):
        graph_from(value.start_node, nodes, edges)
        graph_from(value.end_node, nodes, edges)
        key = str(value.element_id)
        edges[key] = {"id": key, "from": str(value.start_node.element_id),
                      "to": str(value.end_node.element_id), "type": value.type,
                      "properties": convert(dict(value))}
    elif isinstance(value, Path):
        for n in value.nodes:
            graph_from(n, nodes, edges)
        for r in value.relationships:
            graph_from(r, nodes, edges)
    elif isinstance(value, dict):
        for v in value.values():
            graph_from(v, nodes, edges)
    elif isinstance(value, (list, tuple)):
        for v in value:
            graph_from(v, nodes, edges)

@app.get("/")
def index():
    return render_template("index.html")

@app.get("/health")
def health():
    try:
        driver.verify_connectivity()
        return jsonify({"status": "ready"})
    except Exception as exc:
        return jsonify({"status": "waiting", "error": str(exc)}), 503

@app.post("/api/query")
def query():
    data = request.get_json(silent=True) or {}
    cypher = data.get("query", "")
    if not isinstance(cypher, str) or not cypher.strip():
        return jsonify({"error": "Enter a Cypher query."}), 400
    if len(cypher) > 20000:
        return jsonify({"error": "Query is too long."}), 400
    try:
        with driver.session(database="neo4j") as session:
            result = session.run(cypher)
            columns = result.keys()
            rows, nodes, edges = [], {}, {}
            for record in result:
                if len(rows) >= 200:
                    break
                values = [record[k] for k in columns]
                for value in values:
                    graph_from(value, nodes, edges)
                rows.append([convert(v) for v in values])
            summary = result.consume()
            return jsonify({
                "columns": columns, "rows": rows,
                "nodes": list(nodes.values()), "edges": list(edges.values()),
                "limited": len(rows) >= 200,
                "counters": str(summary.counters),
            })
    except Exception as exc:
        return jsonify({"error": str(exc)}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8501)
