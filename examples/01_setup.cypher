// Re-runnable university graph: four students, three courses, six relationships.
CREATE CONSTRAINT student_id_unique IF NOT EXISTS
FOR (s:Student) REQUIRE s.id IS UNIQUE;

CREATE CONSTRAINT course_code_unique IF NOT EXISTS
FOR (c:Course) REQUIRE c.code IS UNIQUE;

MERGE (alice:Student {id: 1}) SET alice.name = 'Alice'
MERGE (bob:Student {id: 2}) SET bob.name = 'Bob'
MERGE (carol:Student {id: 3}) SET carol.name = 'Carol'
MERGE (dan:Student {id: 4}) SET dan.name = 'Dan'
MERGE (db:Course {code: 'CSCI 480'}) SET db.title = 'Advanced Databases'
MERGE (arch:Course {code: 'CSCI 355'}) SET arch.title = 'Computer Architecture'
MERGE (ai:Course {code: 'CSCI 405'}) SET ai.title = 'Artificial Intelligence'
MERGE (alice)-[:ENROLLED_IN]->(db)
MERGE (alice)-[:ENROLLED_IN]->(arch)
MERGE (bob)-[:ENROLLED_IN]->(db)
MERGE (bob)-[:ENROLLED_IN]->(ai)
MERGE (carol)-[:ENROLLED_IN]->(arch)
MERGE (dan)-[:ENROLLED_IN]->(db);

MATCH (s:Student) RETURN count(s) AS students;
MATCH (c:Course) RETURN count(c) AS courses;
MATCH ()-[r:ENROLLED_IN]->() RETURN count(r) AS enrollments;
