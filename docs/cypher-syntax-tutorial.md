# Cypher syntax tutorial — Student–Course graph

**CSCI 480 / CIS 680 Advanced Databases**

This short tutorial explains the syntax used in [the sample dataset](../examples/01_setup.cypher) and [the seven example queries](../examples/02_queries.cypher). It assumes the original sample graph has been loaded, before exercise 6 adds Eve.

## Getting started

In the Codespaces terminal, load the example graph once:

```bash
bash scripts/run.sh examples/01_setup.cypher
```

When Codespaces starts, accept the popup to open **Cypher Practice** (port **8501**). If you dismissed it, open port 8501 from the **Ports** tab. **Run one complete Cypher statement at a time** in the web editor.

The starting graph contains four students (Alice, Bob, Carol, Dan), three courses (CSCI 480, CSCI 355, CSCI 405), and six `ENROLLED_IN` relationships:

| Student | Enrolled courses |
| --- | --- |
| Alice | CSCI 480, CSCI 355 |
| Bob | CSCI 480, CSCI 405 |
| Carol | CSCI 355 |
| Dan | CSCI 480 |

## 1. Nodes, labels, variables, and properties

```cypher
MATCH (s:Student)
RETURN s.id, s.name
ORDER BY s.id;
```

| Syntax | Meaning |
| --- | --- |
| `MATCH` | Find a graph pattern; similar in purpose to querying rows with SQL `SELECT` |
| `( ... )` | A **node pattern** |
| `s` | A **variable** referring to each matched node; the variable name is not stored in the database |
| `:Student` | The node's **label**, identifying its type |
| `s.id`, `s.name` | Access the node's `id` and `name` **properties** |
| `RETURN` | Choose the values or graph objects to output |
| `ORDER BY s.id` | Sort by student ID (ascending by default) |
| `;` | Statement terminator, used throughout this lab |

**Expected result:** Alice, Bob, Carol, and Dan, ordered by IDs 1–4.

A node pattern can also include a **property map**:

```cypher
MATCH (s:Student {id: 1})
RETURN s.name;
```

`{id: 1}` means match a `Student` whose `id` property is 1. The braces contain key–value pairs. Strings use quotes, such as `{name: 'Alice'}`.

## 2. Create or reuse data: MERGE and SET

The setup file includes:

```cypher
MERGE (alice:Student {id: 1})
SET alice.name = 'Alice';
```

- `MERGE` finds a node matching `(:Student {id: 1})`, or creates one if none matches.
- `alice` is a **query variable**, not the student's stored name.
- `SET alice.name = 'Alice'` assigns or updates the `name` property.
- `'Alice'` is the **string value** stored in that property.

This resembles an SQL **UPSERT**, although `MERGE` matches graph patterns rather than SQL rows. The setup also defines uniqueness constraints for student IDs and course codes.

**Contrast:** `CREATE` always attempts to create a new pattern; `MERGE` reuses a matching pattern. Re-running this example is intended to be safe because the match uses the unique student ID.

## 3. Relationships and direction: arrows

```cypher
MATCH (s:Student)-[:ENROLLED_IN]->(c:Course {code: 'CSCI 480'})
RETURN s.name AS student, c.title AS course
ORDER BY student;
```

Read the pattern **from left to right**: a Student node has an outgoing `ENROLLED_IN` relationship to a Course node.

| Syntax | Meaning |
| --- | --- |
| `(s:Student)` | Student node |
| `-[ ... ]->` | A **directed relationship** pointing toward the course |
| `:ENROLLED_IN` | Relationship **type** |
| `(c:Course {code: 'CSCI 480'})` | Course node with the specified code |
| `AS student` | Rename an output column |
| `ORDER BY student` | Sort alphabetically by the output alias |

**Expected result:** Alice, Bob, and Dan, each paired with *Advanced Databases*.

You can also assign a variable to a relationship:

```cypher
MATCH (s:Student)-[r:ENROLLED_IN]->(c:Course)
RETURN s, r, c;
```

Here `r` refers to the relationship itself. Returning **nodes and relationships** lets the Cypher Practice **Graph** tab draw the network. Returning only names and counts is better viewed as a **Table**.

## 4. Two-hop patterns, WHERE, and DISTINCT

Example 4 finds Alice's classmates:

```cypher
MATCH (alice:Student {name: 'Alice'})-[:ENROLLED_IN]->(c:Course)<-[:ENROLLED_IN]-(other:Student)
WHERE other <> alice
RETURN DISTINCT other.name AS classmate
ORDER BY classmate;
```

The path goes **Alice → Course ← Other student**. The second arrow points *into* the course because the other student's enrollment also goes from Student to Course.

- `WHERE other <> alice`: exclude Alice herself; `<>` means **not equal**.
- `DISTINCT`: return each classmate only once, even if multiple shared courses produce duplicate matches.
- `other.name AS classmate`: return a readable name with a column alias.

**Expected result:** Bob, Carol, and Dan. Bob and Dan share CSCI 480 with Alice; Carol shares CSCI 355.

## 5. OPTIONAL MATCH and COUNT: include zero enrollments

```cypher
MATCH (c:Course)
OPTIONAL MATCH (s:Student)-[:ENROLLED_IN]->(c)
RETURN c.code AS course, count(s) AS enrolled
ORDER BY enrolled DESC, course;
```

- First, `MATCH (c:Course)` finds **every course**.
- `OPTIONAL MATCH` tries to find enrolled students **without dropping courses that have none**. This is similar to SQL `LEFT OUTER JOIN`.
- If no student matches, `s` is `null`; `count(s)` ignores `null`, producing **0** for that course.
- `count(s)` is an **aggregate function**. Since `c.code` is also returned, results are grouped by course code.
- `DESC` means descending (largest count first); `course` breaks ties alphabetically.

**Expected result with the initial dataset:**

| course | enrolled |
| --- | ---: |
| CSCI 480 | 3 |
| CSCI 355 | 2 |
| CSCI 405 | 1 |

There are no zero-enrollment courses initially. The difference becomes visible if a course without students is added: ordinary `MATCH` would omit it, while `OPTIONAL MATCH` retains it with count 0.

## 6. WITH, aggregation, and filtering aggregate results

```cypher
MATCH (s:Student)-[:ENROLLED_IN]->(c:Course)
WITH s, count(DISTINCT c) AS courseCount
WHERE courseCount >= 2
RETURN s.name AS student, courseCount
ORDER BY student;
```

- `WITH` passes selected variables and calculated values into the **next part** of the query.
- `count(DISTINCT c)` counts **different courses** for each student.
- `WITH s, ...` groups the count by student.
- `AS courseCount` gives the aggregate a name that the following clauses can use.
- `WHERE courseCount >= 2` keeps students enrolled in at least two courses; `>=` means greater than or equal to.

**Expected result:** Alice (2), Bob (2).

For students familiar with SQL, this resembles `GROUP BY` followed by `HAVING COUNT(DISTINCT ...) >= 2`. Cypher uses `WITH` to separate the aggregation from the subsequent filter.

## 7. Quick reference

| Cypher | Role | Rough SQL counterpart |
| --- | --- | --- |
| `(s:Student)` | Node pattern with label | Table/row reference |
| `{id: 1}` | Property map | Column equality condition |
| `MERGE` | Match or create a pattern | UPSERT-like operation |
| `SET` | Assign/update property | UPDATE SET |
| `MATCH` | Find a graph pattern | SELECT with matching conditions/joins |
| `-[:ENROLLED_IN]->` | Directed typed relationship | Join through a relationship table |
| `WHERE` | Filter matches | WHERE |
| `OPTIONAL MATCH` | Preserve unmatched input rows | LEFT OUTER JOIN |
| `RETURN` | Choose output columns/objects | SELECT list |
| `AS` | Output alias | AS |
| `DISTINCT` | Eliminate duplicates | DISTINCT |
| `count()` | Aggregate count | COUNT() |
| `WITH` | Intermediate projection/aggregation | Subquery or CTE (roughly) |
| `ORDER BY`, `DESC` | Sort output | ORDER BY, DESC |

These SQL comparisons are **analogies**, not exact syntax translations: Cypher matches **graph patterns** directly, rather than joining tables explicitly.

## 8. Practice

After reading the tutorial, try the [student exercises](../exercises/README.md) and fill in [student_template.cypher](../exercises/student_template.cypher). Exercise 6 adds Eve (ID 5) to CSCI 480; after that, some expected results above will change.

**Note:** Undo in the text editor does **not** reverse a Cypher write query that has already run. To change the graph again, execute another Cypher statement.
