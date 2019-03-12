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
SELECT S.StudentRegistrationId, SD.DegreeId, SD.StudentId, G.GPA FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S, StudentGPA AS G
WHERE S.StudentRegistrationId = SD.StudentRegistrationId
AND SD.DegreeId = D.DegreeId
AND S.sumECTS >= TotalECTS
AND G.GPA > 9.9
AND G.StudentRegistrationId = SD.StudentRegistrationId
),
FailedCourse AS (
SELECT CD.StudentRegistrationId FROM CompletedDegree AS CD
LEFT OUTER JOIN CourseRegistrations AS CR ON CD.StudentRegistrationId = CR.StudentRegistrationId
WHERE Grade < 5
)
SELECT CD.StudentId FROM CompletedDegree AS CD
LEFT OUTER JOIN FailedCourse ON CD.StudentRegistrationId = FailedCourse.StudentRegistrationId
WHERE FailedCourse.StudentRegistrationId IS NULL GROUP BY CD.StudentId ORDER BY CD.StudentId;

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
SELECT A.DegreeId, BirthYearStudent, Gender, AVG(GPA) AS AvgGrade
FROM ActiveStudents AS A, Students AS S, StudentGPA
WHERE A.StudentRegistrationId = StudentGPA.StudentRegistrationId
GROUP BY A.DegreeId, CUBE(BirthYearStudent, Gender);

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

SELECT S.StudentRegistrationId FROM StudentAssistants AS S, CourseRegistrations AS CR
WHERE S.StudentRegistrationId = CR.StudentRegistrationId
AND S.CourseOfferId = CR.CourseOfferId;
