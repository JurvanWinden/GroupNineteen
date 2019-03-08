--The 8 queries to be answered
-- Q1
SELECT CourseName, Grade, SD.DegreeId FROM PassedCoursesPerStudentRegId AS P, Courses AS C, StudentRegistrationsToDegrees as SD
WHERE P.StudentRegistrationId = SD.StudentRegistrationId
AND SD.StudentId = 3831503 -- replace %1%
AND SD.DegreeId = 5123 -- replace %2%
AND P.CourseId = C.CourseId;

-- Q2 Select all excellent students GPA high, no failed courses in a degree
-- Runs in approx 0.4 seconds with view to be runned 10 times
SELECT StudentId FROM StudentGPA, StudentRegistrationsToDegrees
WHERE GPA >= 9.4;

-- Q3
-- Runs in approx 74 seconds... to be runned 1 time
WITH ActiveStudents AS (
    SELECT SD.StudentId, D.DegreeId FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, PassedCoursesPerStudentRegId AS P, Courses AS C
    WHERE (P.StudentRegistrationId = SD.StudentRegistrationId OR SD.StudentRegistrationId NOT IN (SELECT StudentRegistrationId FROM PassedCoursesPerStudent))
    AND SD.DegreeId = D.DegreeId
    AND P.CourseId = C.CourseId
    AND D.DegreeId = C.DegreeId
    GROUP BY SD.StudentId, TotalECTS, D.DegreeId
    HAVING SUM(P.ECTS) < TotalECTS
),
ActiveFemaleStudents AS (
    SELECT A.DegreeId, COUNT(A.StudentId) AS Active FROM ActiveStudents AS A
    INNER JOIN Students
    ON Students.StudentId =  A.StudentId
    WHERE Gender = 'F'
    GROUP BY A.DegreeId
)
SELECT A.DegreeId, (AF.Active / CAST (COUNT(A.StudentId) AS DECIMAL)) AS Percentage FROM ActiveStudents AS A, ActiveFemaleStudents AS AF
WHERE A.DegreeId = AF.DegreeId
GROUP BY A.DegreeId, AF.Active;

--Q4 Give percentage of female students for all degrees of a department
-- Runs in approx 2.8 seconds... is to be runned 10 times CORRECT
WITH StudentCount AS (
    SELECT COUNT(Students.StudentId) AS SC FROM Degrees, StudentRegistrationsToDegrees, Students
    WHERE Students.StudentId = StudentRegistrationsToDegrees.StudentId
    AND StudentRegistrationsToDegrees.DegreeId = Degrees.DegreeId
    AND Dept = 'be to thin' -- replace this with var
    GROUP BY Degrees.Dept
),
FemaleStudentCount AS (
    SELECT COUNT(Students.StudentId) AS FSC FROM Degrees, StudentRegistrationsToDegrees, Students
    WHERE Students.StudentId = StudentRegistrationsToDegrees.StudentId
    AND StudentRegistrationsToDegrees.DegreeId = Degrees.DegreeId
    AND Gender = 'F'
    AND Degrees.Dept = 'be to thin' -- replace this with %1%
    GROUP BY Degrees.Dept
)
SELECT (FSC / CAST(SC AS DECIMAL)) AS Percentage FROM FemaleStudentCount, StudentCount;

--Q5 Give percentage of passed students of all courses over all courseoffers with passing grade %1%
-- Runs in appox 95 seconds... to be runned 5 times

WITH StudentCount AS (
SELECT CourseId, COUNT(CR.StudentRegistrationId) AS SC FROM CourseOffers AS CO, CourseRegistrations AS CR
WHERE CO.CourseOfferId = CR.CourseOfferId
AND Grade IS NOT NULL
GROUP BY CourseId
),
PassedStudentCount AS (
SELECT CourseId, COUNT(CR.StudentRegistrationId) AS PSC FROM CourseOffers AS CO, CourseRegistrations AS CR
WHERE CO.CourseOfferId = CR.CourseOfferId
AND Grade >= 5
AND Grade IS NOT NULL
GROUP BY CourseId
)
SELECT PassedStudentCount.CourseId, (PSC / CAST(SC AS DECIMAL) * 100) AS Percentage FROM StudentCount, PassedStudentCount
WHERE StudentCount.CourseId = PassedStudentCount.CourseId;

--Q6 excellent students 2.0, highest grade of each course, etc
-- Runs in approx 21 seconds... is to be runned 3 times
WITH BestGrades AS (
    SELECT StudentId FROM CourseOffers AS CO, PassedCoursesPerStudentRegId AS P
    WHERE CO.CourseId = P.CourseId
    AND Year = 2018
    AND Quartile = 1
    GROUP BY StudentId, Grade
    HAVING Grade = MAX(Grade)
)
SELECT StudentId, COUNT(StudentId) AS NumberOfCoursesWhereExcellent FROM BestGrades
GROUP BY StudentId HAVING COUNT(StudentId) >= 3;

-- Q7
SELECT sd.DegreeId, BirthYearStudent, Gender, AVG(Grade)
FROM CourseRegistrations as cr, CourseOffers as co, Courses as c, Students as s, StudentRegistrationsToDegrees as sd
WHERE cr.CourseOfferId = co.CourseOfferId
AND	co.CourseId = c.CourseId
AND cr.StudentRegistrationId = sd.StudentRegistrationId
AND s.StudentId = sd.StudentId
GROUP BY CUBE(sd.DegreeId, BirthYearStudent, Gender);

-- Q8 List all CourseOffers which did not have enough student assistants
-- Runs in approx 107 seconds... to be runned 1 time
WITH SC AS (SELECT CourseRegistrations.CourseOfferId, COUNT(CourseRegistrations.StudentRegistrationId) as StudentCount
FROM CourseRegistrations
GROUP BY CourseRegistrations.CourseOfferId
),
AC AS (SELECT CourseOfferId, COUNT(StudentAssistants.StudentRegistrationId) as StudentAssistantCount
FROM StudentAssistants
GROUP BY StudentAssistants.CourseOfferId
)
SELECT Courses.CourseName, CourseOffers.Year, CourseOffers.Quartile
FROM Courses, CourseOffers, SC, AC
WHERE SC.CourseOfferId = AC.CourseOfferId AND
AC.CourseOfferId = CourseOffers.CourseOfferId AND
CourseOffers.CourseId = Courses.CourseId AND
(AC.StudentAssistantCount * 50 <= SC.StudentCount)
ORDER BY SC.CourseOfferId;



WITH BestGrades AS (SELECT CourseOffers.CourseOfferId, MAX(Grade) AS Best
FROM CourseOffers, CourseRegistrations
WHERE CourseOffers.CourseOfferId = CourseRegistrations.CourseOfferId AND Year = 2018 AND Quartile = 1 GROUP BY CourseOffers.CourseOfferId)
SELECT StudentId, COUNT(CourseRegistrations.StudentRegistrationId) AS NumberOfCoursesWhereExcellent
FROM StudentRegistrationsToDegrees, CourseRegistrations, BestGrades
WHERE CourseRegistrations.CourseOfferId = BestGrades.CourseOfferId
AND StudentRegistrationsToDegrees.StudentRegistrationId = CourseRegistrations.StudentRegistrationId
AND Grade = BestGrades.Best GROUP BY StudentId HAVING COUNT(CourseRegistrations.StudentRegistrationId) >= 1 ORDER BY StudentId, NumberOfCoursesWhereExcellent;

SELECT SD.StudentId FROM StudentRegistrationsToDegrees AS SD
WHERE SD.StudentRegistrationId NOT IN (SELECT SD.StudentRegistrationId FROM CourseOffers AS CO, Courses AS C, StudentRegistrationsToDegrees AS SD, CourseRegistrations as CR
WHERE CO.CourseOfferId = CR.CourseOfferId
AND SD.StudentRegistrationId = CR.StudentRegistrationId
AND C.CourseId = CO.CourseId
AND C.DegreeId = SD.DegreeId);

-- All students that are registered for a degree but do not have any courses
SELECT SD.StudentRegistrationId FROM CourseOffers AS CO, Courses AS C, StudentRegistrationsToDegrees AS SD, CourseRegistrations as CR
WHERE CO.CourseOfferId = CR.CourseOfferId
AND SD.StudentRegistrationId = CR.StudentRegistrationId
AND C.CourseId = CO.CourseId
AND C.DegreeId = SD.DegreeId;

SELECT StudentRegistrationId, C.CourseId, Grade, C.DegreeId FROM Courses AS C, CourseOffers AS CO, CourseRegistrations AS CR, StudentRegistrationsToDegrees AS SD
WHERE CO.CourseOfferId = CR.CourseOfferId
AND SD.StudentRegistrationId = CR.StudentRegistrationId
AND CO.CourseId = C.CourseId
AND Grade IS NOT NULL
ORDER BY Year, Quartile, CO.CourseOfferId;
