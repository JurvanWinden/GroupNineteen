-- Q1
-- IS CORRECT (With index use)
SELECT  CourseName, Grade FROM CourseRegistrations AS CR, StudentRegistrationsToDegrees as SD, CourseOffers AS CO, Courses AS C
WHERE SD.StudentId = 1194819 -- replace %1%
AND SD.DegreeId = 1659 -- replace %2%
AND CR.StudentRegistrationId = SD.StudentRegistrationId
AND CR.CourseOfferId = CO.CourseOfferId
AND C.CourseId = CO.CourseId
AND Grade >= 5
ORDER BY Year, Quartile, CR.CourseOfferId;

-- Q2 Select all excellent students GPA high, no failed courses in a degree
WITH CompletedDegree AS (
SELECT S.StudentRegistrationId FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S
WHERE S.StudentRegistrationId = SD.StudentRegistrationId
AND SD.DegreeId = D.DegreeId
AND S.sumECTS >= TotalECTS
),
FailedCourse AS (
SELECT CD.StudentRegistrationId FROM CompletedDegree AS CD
LEFT OUTER JOIN CourseRegistrations AS CR ON CD.StudentRegistrationId = CR.StudentRegistrationId
WHERE Grade < 5
)
SELECT SD.StudentId FROM StudentRegistrationsToDegrees AS SD
LEFT OUTER JOIN FailedCourse ON SD.StudentRegistrationId = FailedCourse.StudentRegistrationId
LEFT OUTER JOIN CompletedDegree ON CompletedDegree.StudentRegistrationId = SD.StudentRegistrationId
WHERE FailedCourse.StudentRegistrationId IS NULL
AND CompletedDegree.StudentRegistrationId = SD.StudentRegistrationId
GROUP BY SD.StudentId ORDER BY SD.StudentId;


WITH FailedCourse AS (
SELECT CR.StudentRegistrationId FROM CourseRegistrations AS CR
WHERE Grade < 5
AND Grade IS NOT NULL
),
CompletedDegree AS (
SELECT S.StudentRegistrationId, SUM(ECTS * Grade) / CAST (SUM(ECTS) AS DECIMAL) AS GPA FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S, CourseRegistrations AS CR, CourseOffers AS CO, Courses AS C
WHERE S.StudentRegistrationId = SD.StudentRegistrationId
AND SD.DegreeId = D.DegreeId
AND S.sumECTS >= TotalECTS
AND CR.StudentRegistrationId = SD.StudentRegistrationId
AND CO.CourseOfferId = CR.CourseOfferId
AND C.CourseId = CO.CourseId
AND Grade >= 5 GROUP BY S.StudentRegistrationId)
SELECT StudentId FROM StudentRegistrationsToDegrees AS SD
LEFT OUTER JOIN CompletedDegree AS C ON C.StudentRegistrationId = SD.StudentRegistrationId
LEFT OUTER JOIN FailedCourse AS F ON F.StudentRegistrationId = SD.StudentRegistrationId
WHERE F.StudentRegistrationId IS NULL
AND C.StudentRegistrationId = SD.StudentRegistrationId
GROUP BY StudentId
ORDER BY StudentId;

SELECT S.StudentRegistrationId, C.CourseId FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S, CourseRegistrations AS CR, CourseOffers AS CO, Courses AS C
WHERE S.StudentRegistrationId = SD.StudentRegistrationId
AND SD.DegreeId = D.DegreeId
AND S.sumECTS >= TotalECTS
AND CR.StudentRegistrationId = SD.StudentRegistrationId
AND CO.CourseOfferId = CR.CourseOfferId
AND C.CourseId = CO.CourseId
AND Grade >= 5 ORDER BY S.StudentRegistrationId, C.CourseId;

-- Q3 Give percentage of female active students per degree
-- IS CORRECT
WITH ActiveStudents AS (
    WITH CompletedDegree AS (
    SELECT S.StudentRegistrationId FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S
    WHERE S.StudentRegistrationId = SD.StudentRegistrationId
    AND SD.DegreeId = D.DegreeId
    AND S.sumECTS >= TotalECTS
    )
    SELECT StudentId, DegreeId FROM StudentRegistrationsToDegrees AS SD
    LEFT OUTER JOIN CompletedDegree ON SD.StudentRegistrationId = CompletedDegree.StudentRegistrationId
    WHERE CompletedDegree.StudentRegistrationId IS NULL
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
GROUP BY A.DegreeId, AF.Active ORDER BY A.DegreeId, AF.Active;

--Q4 Give percentage of female students for all degrees of a department
-- IS CORRECT
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
-- IS CORRECT
WITH StudentCount AS (
SELECT CO.CourseId, COUNT(CO.CourseId) AS SC FROM CourseOffers AS CO LEFT OUTER JOIN CourseRegistrations AS CR ON CO.CourseOfferId = CR.CourseOfferId
WHERE Grade IS NOT NULL GROUP BY CO.CourseId
),
PassedStudentCount AS (
SELECT CO.CourseId, COUNT(CO.CourseId) AS PSC FROM CourseOffers AS CO LEFT OUTER JOIN CourseRegistrations AS CR ON CO.CourseOfferId = CR.CourseOfferId
WHERE Grade IS NOT NULL AND Grade >= 4 GROUP BY CO.CourseId
)
SELECT PS.CourseId , (PSC / CAST (SC AS DECIMAL)) AS Percentage FROM StudentCount as S, Courses AS C, PassedStudentCount AS PS
WHERE C.CourseId = S.CourseId
AND PS.CourseId = S.CourseId
ORDER BY PS.CourseId;

--Q6 excellent students 2.0, highest grade of each course, etc
-- IS CORRECT
WITH BestGrades AS (
WITH NeededCourseOffers AS (
    SELECT CourseOfferId FROM CourseOffers WHERE Year = 2018 AND Quartile = 1
)
SELECT NeededCourseOffers.CourseOfferId, MAX(Grade) AS Best FROM NeededCourseOffers
JOIN CourseRegistrations ON NeededCourseOffers.CourseOfferId = CourseRegistrations.CourseOfferId
GROUP BY NeededCourseOffers.CourseOfferId
)
SELECT StudentId, COUNT(StudentId) AS NumberOfCoursesWhereExcellent FROM CourseRegistrations AS CR
LEFT OUTER JOIN BestGrades ON BestGrades.CourseOfferId = CR.CourseOfferId
LEFT OUTER JOIN StudentRegistrationsToDegrees ON CR.StudentRegistrationId = StudentRegistrationsToDegrees.StudentRegistrationId
WHERE Best = Grade
GROUP BY StudentId HAVING COUNT(StudentId) >= 3 ORDER BY StudentId;

-- Q7
WITH ActiveStudents AS (
    WITH CompletedDegree AS (
    SELECT S.StudentRegistrationId FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S
    WHERE S.StudentRegistrationId = SD.StudentRegistrationId
    AND SD.DegreeId = D.DegreeId
    AND S.sumECTS >= TotalECTS
    )
    SELECT StudentId, DegreeId, SD.StudentRegistrationId FROM StudentRegistrationsToDegrees AS SD
    LEFT OUTER JOIN CompletedDegree ON SD.StudentRegistrationId = CompletedDegree.StudentRegistrationId
    WHERE CompletedDegree.StudentRegistrationId IS NULL
)
SELECT DegreeId, BirthYearStudent, Gender, AVG(Grade) AS AvgGrade
FROM ActiveStudents AS A, Students AS S, CourseRegistrations AS CR
WHERE  CR.StudentRegistrationId = A.StudentRegistrationId
AND Grade >= 5
GROUP BY DegreeId, CUBE(BirthYearStudent, Gender);

-- Q8 List all CourseOffers which did not have enough student assistants
-- Runs in approx 107 seconds... to be runned 1 time
WITH SC AS (SELECT CourseRegistrations.CourseOfferId, COUNT(CourseOfferId) as StudentCount
FROM CourseRegistrations
GROUP BY CourseRegistrations.CourseOfferId
),
AC AS (SELECT CourseOfferId, COUNT(CourseOfferId) as StudentAssistantCount
FROM StudentAssistants as S
GROUP BY S.CourseOfferId
)
SELECT CourseOffers.CourseOfferId, Courses.CourseName, CourseOffers.Year, CourseOffers.Quartile, AC.StudentAssistantCount * 50, SC.StudentCount
FROM Courses, CourseOffers, SC, AC
WHERE SC.CourseOfferId = AC.CourseOfferId AND
AC.CourseOfferId = CourseOffers.CourseOfferId AND
CourseOffers.CourseId = Courses.CourseId AND
(AC.StudentAssistantCount * 50 < SC.StudentCount)
ORDER BY SC.CourseOfferId;

WITH BestGrades AS (WITH NeededCourseOffers AS (SELECT CourseOfferId FROM CourseOffers WHERE Year = 2018 AND Quartile = 1) SELECT NeededCourseOffers.CourseOfferId, MAX(Grade) AS Best FROM NeededCourseOffers JOIN CourseRegistrations ON NeededCourseOffers.CourseOfferId = CourseRegistrations.CourseOfferId GROUP BY NeededCourseOffers.CourseOfferId) SELECT StudentId, COUNT(StudentId) AS NumberOfCoursesWhereExcellent FROM CourseRegistrations AS CR LEFT OUTER JOIN BestGrades ON BestGrades.CourseOfferId = CR.CourseOfferId LEFT OUTER JOIN StudentRegistrationsToDegrees ON CR.StudentRegistrationId = StudentRegistrationsToDegrees.StudentRegistrationId WHERE Best = Grade GROUP BY StudentId HAVING COUNT(StudentId) >= 3 ORDER BY StudentId;

