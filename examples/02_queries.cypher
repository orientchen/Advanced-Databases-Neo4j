// Read queries: run as a file or copy one complete query at a time into Browser.
// 1. List students.
MATCH (s:Student)
RETURN s.id, s.name
ORDER BY s.id;

// 2. List courses.
MATCH (c:Course)
RETURN c.code, c.title
ORDER BY c.code;

// 3. One-hop: students in Advanced Databases.
MATCH (s:Student)-[:ENROLLED_IN]->(c:Course {code: 'CSCI 480'})
RETURN s.name AS student, c.title AS course
ORDER BY student;

// 4. Two-hop: Alice's classmates.
MATCH (alice:Student {name: 'Alice'})-[:ENROLLED_IN]->(c:Course)<-[:ENROLLED_IN]-(other:Student)
WHERE other <> alice
RETURN DISTINCT other.name AS classmate
ORDER BY classmate;

// 5. Aggregate, including courses with no students.
MATCH (c:Course)
OPTIONAL MATCH (s:Student)-[:ENROLLED_IN]->(c)
RETURN c.code AS course, count(s) AS enrolled
ORDER BY enrolled DESC, course;

// 6. Show all enrollment graph objects.
MATCH (s:Student)-[r:ENROLLED_IN]->(c:Course)
RETURN s, r, c;

// 7. Students taking two or more courses.
MATCH (s:Student)-[:ENROLLED_IN]->(c:Course)
WITH s, count(DISTINCT c) AS courseCount
WHERE courseCount >= 2
RETURN s.name AS student, courseCount
ORDER BY student;
