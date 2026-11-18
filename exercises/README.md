# Student practice — Cypher

**CSCI 480 / CIS 680 Advanced Databases**

First run `bash scripts/run.sh examples/01_setup.cypher`. Write answers in a copy of `student_template.cypher`. End every Cypher statement with a semicolon.

1. **MATCH / ORDER BY:** List all students by name, alphabetically.
2. **Traversal:** List the codes and titles of all courses Bob takes.
3. **Filter:** Find the students enrolled in `CSCI 480`.
4. **Aggregation:** Show enrollment counts for **every** course, including courses with no students.
5. **Two-hop:** Find Alice's classmates (students sharing at least one class). Exclude Alice; avoid duplicate rows.
6. **Write data:** Create Eve (`id: 5`) and enroll her in `CSCI 480`. Use `MERGE` for nodes and relationships so rerunning your solution is safe.
7. **GROUP BY equivalent:** Find students taking two or more courses. Show each name and its distinct course count.
8. **Compare with SQL:** Explain or write the SQL joins required for exercise 5, using `Student(student_id,name)`, `Enrollment(student_id,course_id)`, and `Course(course_id,code,title)`. Why might `DISTINCT` be useful?

**Submit:** Your answer `.cypher` file and a brief written answer to question 8.

**Hint:** Cypher's `OPTIONAL MATCH` resembles an outer join. Cypher's `WITH` can group and filter aggregate results. Try the read-query examples before completing the exercises.

**Note:** Running exercise 6 changes the graph. The original setup contains four students; after adding Eve there are five.
