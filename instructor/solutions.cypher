// INSTRUCTOR ONLY. Do not share this file with student repository readers.
// Solutions in the same order as exercises/README.md.
// 1
MATCH (s:Student)
RETURN s.name AS name
ORDER BY name;

// 2
MATCH (:Student {name: 'Bob'})-[:ENROLLED_IN]->(c:Course)
RETURN c.code AS code, c.title AS title
ORDER BY code;

// 3
MATCH (s:Student)-[:ENROLLED_IN]->(:Course {code: 'CSCI 480'})
RETURN s.name AS student
ORDER BY student;

// 4
MATCH (c:Course)
OPTIONAL MATCH (s:Student)-[:ENROLLED_IN]->(c)
RETURN c.code AS course, count(s) AS enrolled
ORDER BY course;

// 5
MATCH (alice:Student {name: 'Alice'})-[:ENROLLED_IN]->(:Course)<-[:ENROLLED_IN]-(other:Student)
WHERE other <> alice
RETURN DISTINCT other.name AS classmate
ORDER BY classmate;

// 6 (changes the graph)
MERGE (eve:Student {id: 5})
SET eve.name = 'Eve'
WITH eve
MATCH (course:Course {code: 'CSCI 480'})
MERGE (eve)-[:ENROLLED_IN]->(course);

// 7
MATCH (s:Student)-[:ENROLLED_IN]->(c:Course)
WITH s, count(DISTINCT c) AS courseCount
WHERE courseCount >= 2
RETURN s.name AS student, courseCount
ORDER BY student;

// 8. SQL equivalent of exercise 5:
// SELECT DISTINCT other.name
// FROM Student AS alice
// JOIN Enrollment AS ae ON ae.student_id = alice.student_id
// JOIN Enrollment AS oe ON oe.course_id = ae.course_id
// JOIN Student AS other ON other.student_id = oe.student_id
// WHERE alice.name = 'Alice'
//   AND other.student_id <> alice.student_id;
// DISTINCT removes repeated classmates who share multiple courses.
