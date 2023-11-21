-- (Q1)Find the top-3 instructors who have have taught most number of DISTINCT courses from
-- (a)Across all departments

SELECT instructor.id, instructor.name, instructor. dept_name,
count(DISTINCT course_id) AS number_of_courses
FROM instructor
LEFT JOIN teaches
ON teaches.id = instructor.id
GROUP BY instructor.id
ORDER BY count(DISTINCT course_id) DESC
LIMIT 3;

-- (b)Statistics department

SELECT instructor.id, instructor.name, instructor. dept_name,
count(DISTINCT course_id) AS number_of_courses
FROM instructor
LEFT JOIN teaches
ON teaches.id = instructor.id
WHERE instructor.dept_name = 'Statistics'
GROUP BY instructor.id,instructor.name
ORDER BY count(DISTINCT course_id) DESC
LIMIT 3;

-- (Q2)Print teaching record of the instructor who hAS the highest salary, 
-- showing the instructor department name, course identifier, course title, section number, semester, year and total enrollment.
-- Sort your result by course_id, year, semester in ASCending order. 

SELECT instructor.dept_name, course.course_id AS course_identifier,
course.title AS course_title,teaches.sec_id,teaches.semester,
teaches.year,instructor.salary, count(*) AS total_enrollment
FROM instructor
INNER JOIN teaches
ON instructor.id = teaches.id
INNER JOIN course
ON teaches.course_id = course.course_id
INNER JOIN takes
ON takes.course_id = course.course_id
WHERE instructor.id IN (
    SELECT id from instructor
    ORDER BY salary DESC
    LIMIT 1
)
GROUP BY instructor.dept_name, course.course_id,
course.title,teaches.sec_id,teaches.semester,teaches.year,instructor.salary
ORDER BY course.course_id, teaches.year, teaches.semester;

-- (Q3) Print history of the course with course_id = 362.
-- For each offering of the course, print course id, course title,
-- course department name, instructor name, number of registered students,
-- section id, semester, year and timetable slot. 
-- Sort your result by year in DESCending order.

SELECT course.course_id, course.title AS course_title, course.dept_name,
instructor.name AS instructor_name,
count(takes.id) AS numer_of_students,
teaches.sec_id, teaches.semester,
teaches.year, section.time_slot_id
FROM course
INNER JOIN teaches
ON teaches.course_id=course.course_id
INNER JOIN instructor
ON instructor.id = teaches.id
INNER JOIN takes
ON takes.course_id=course.course_id AND takes.year=teaches.year
INNER JOIN section
ON section.course_id=teaches.course_id AND section.year=teaches.year
WHERE course.course_id = '362'
GROUP BY course.course_id, course.title, course.dept_name, instructor.name,
teaches.year, teaches.sec_id, teaches.semester, teaches.year, section.time_slot_id
ORDER BY teaches.year DESC;

-- (Q4)For the course_id 319 that wAS offered in 2003, find
--  the count of out of department student registratiON. 

WITH course_dept AS (
    SELECT DISTINCT dept_name
    FROM course
    WHERE course_id = '319'
)
, student_in_course AS (
    SELECT id
    FROM takes
    WHERE course_id = '319' AND year = 2003
)

SELECT count(id) AS number_of_out_of_department_students
FROM student
WHERE id IN (SELECT id FROM student_in_course) AND dept_name NOT IN (SELECT dept_name FROM course_dept);

-- (Q5) Find top-3 students who have registered for the highest number of course credits. 
-- ORDER BY total credits and name. Print student id, name, department and total credits 
-- (Compute it from the takes and course tables. Do not use tot_credit in the student table.) 

SELECT student.id, student.name,student.dept_name,sum(course.credits) AS total_credits
FROM takes
INNER JOIN course
ON course.course_id=takes.course_id
INNER JOIN student
ON takes.id = student.id
GROUP BY takes.id,student.id
ORDER BY sum(course.credits) DESC , student.name ASC
LIMIT 3;

-- (Q6)Find the DISTINCT set of courses that were not offered during 2003 and 2004.
-- Print the course id and title. Sort your result by course id in ASCending order.    

SELECT course.course_id, course.title
FROM course
WHERE course.course_id NOT IN (SELECT DISTINCT course_id
FROM teaches
WHERE year=2003 OR year=2004)
ORDER BY course_id ASC;

-- (Q7)Find the courses that were offered for the first time most recently in terms of year. 
-- Print the course id, title, instructor, year. Sort your result by course id in ASCending order. 
-- [Find the most recent year when a course wAS offered for the first time. 
-- If there are more than ONe course offered that year for the first time, then print all of them.]

WITH first_offered AS (SELECT course_id, MIN(year) AS year
FROM teaches
GROUP BY course_id)
,maxi AS (SELECT Max(year) AS year
FROM first_offered)
,recent_course_ids AS (SELECT first_offered.course_id AS course_id, first_offered.year
FROM first_offered, maxi
WHERE first_offered.year = maxi.year
ORDER BY first_offered.course_id)

SELECT course.course_id, course.title, instructor.name AS instructor_name, recent_course_ids.year
FROM instructor
INNER JOIN teaches
ON teaches.id=instructor.id
INNER JOIN recent_course_ids
ON teaches.course_id = recent_course_ids.course_id
INNER JOIN course
ON course.course_id = teaches.course_id
ORDER BY course.course_id;

-- (Q8)Find all the courses whose title hAS more than 15 characters and have a ‘sys’ AS substring in the title.
-- CONsider cASe insensitive matching. 'sys', 'Sys', etc are all fine. Print the course id and title. Sort result by course id.

SELECT title, course_id
FROM course
WHERE title ILIKE '%sys%' AND length(title)>15
ORDER BY course_id;

-- (Q9)Find the department that offers the highest average salary to instructors.

Select dept_name,avg(salary) AS avg_salary
FROM instructor
GROUP BY dept_name
ORDER BY avg(salary) DESC
LIMIT 1;

-- (Q10)Find all instructors who taught at most ONce in 2003. 
-- (Didn’t teach any course in 2003 or taught just ONe course in 2003). 
-- Print instructor id, name and department. Sort your result by instructor id.

(SELECT instructor.id, instructor.name, instructor.dept_name
FROM instructor
WHERE instructor.id IN(SELECT id
FROM teaches
WHERE year = 2003
GROUP BY id
Having count(course_id)=1))
UNION
(SELECT instructor.id, instructor.name, instructor.dept_name
FROM instructor
WHERE instructor.id NOT IN(SELECT DISTINCT id
FROM teaches
WHERE year = 2003))
ORDER BY id;

-- Himanshu Jindal
-- MA21BTECH11007