SELECT P.CourseName, P.Grade FROM PassedCoursesPerStudentRegId AS P, StudentRegistrationsToDegrees as SD, CourseOffers AS CO, Courses AS C WHERE P.StudentRegistrationId = SD.StudentRegistrationId AND SD.StudentId = %1% AND SD.DegreeId = %2% AND P.CourseOfferId = CO.CourseOfferId AND C.CourseId = CO.CourseId;
WITH CompletedDegree AS (SELECT S.StudentRegistrationId, SD.DegreeId, SD.StudentId FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S, StudentGPA AS G WHERE S.StudentRegistrationId = SD.StudentRegistrationId AND SD.DegreeId = D.DegreeId AND S.sumECTS >= TotalECTS AND G.GPA >= %1% AND G.StudentRegistrationId = S.StudentRegistrationId), FailedCourse AS (SELECT CD.StudentId FROM CompletedDegree AS CD LEFT OUTER JOIN CourseRegistrations AS CR ON CD.StudentRegistrationId = CR.StudentRegistrationId WHERE Grade < 5) SELECT CD.StudentId FROM CompletedDegree AS CD LEFT OUTER JOIN FailedCourse ON CD.StudentId = FailedCourse.StudentId WHERE FailedCourse.StudentId IS NULL ORDER BY CD.StudentId;
WITH ActiveStudents AS (WITH CompletedDegree AS (SELECT S.StudentRegistrationId FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S WHERE S.StudentRegistrationId = SD.StudentRegistrationId AND SD.DegreeId = D.DegreeId AND S.sumECTS >= TotalECTS) SELECT StudentId, DegreeId FROM StudentRegistrationsToDegrees AS SD LEFT OUTER JOIN CompletedDegree ON SD.StudentRegistrationId = CompletedDegree.StudentRegistrationId WHERE CompletedDegree.StudentRegistrationId IS NULL), ActiveFemaleStudents AS (SELECT A.DegreeId, COUNT(A.StudentId) AS Active FROM ActiveStudents AS A INNER JOIN Students ON Students.StudentId =  A.StudentId WHERE Gender = 'F' GROUP BY A.DegreeId) SELECT A.DegreeId, (AF.Active / CAST (COUNT(A.StudentId) AS DECIMAL)) AS Percentage FROM ActiveStudents AS A, ActiveFemaleStudents AS AF WHERE A.DegreeId = AF.DegreeId GROUP BY A.DegreeId, AF.Active ORDER BY A.DegreeId, AF.Active;
WITH StudentCount AS (SELECT COUNT(Students.StudentId) AS SC FROM Degrees, StudentRegistrationsToDegrees, Students WHERE Students.StudentId = StudentRegistrationsToDegrees.StudentId AND StudentRegistrationsToDegrees.DegreeId = Degrees.DegreeId AND Dept = %1% GROUP BY Degrees.Dept), FemaleStudentCount AS (SELECT COUNT(Students.StudentId) AS FSC FROM Degrees, StudentRegistrationsToDegrees, Students WHERE Students.StudentId = StudentRegistrationsToDegrees.StudentId AND StudentRegistrationsToDegrees.DegreeId = Degrees.DegreeId AND Gender = 'F' AND Degrees.Dept = %1% GROUP BY Degrees.Dept) SELECT (FSC / CAST(SC AS DECIMAL)) AS Percentage FROM FemaleStudentCount, StudentCount;
SELECT 0;
WITH BestGrades AS (WITH NeededCourseOffers AS (SELECT CourseOfferId FROM CourseOffers WHERE Year = 2018 AND Quartile = 1) SELECT NeededCourseOffers.CourseOfferId, MAX(Grade) AS Best FROM NeededCourseOffers JOIN CourseRegistrations ON NeededCourseOffers.CourseOfferId = CourseRegistrations.CourseOfferId GROUP BY NeededCourseOffers.CourseOfferId) SELECT StudentId, COUNT(StudentId) AS NumberOfCoursesWhereExcellent FROM CourseRegistrations AS CR LEFT OUTER JOIN BestGrades ON BestGrades.CourseOfferId = CR.CourseOfferId LEFT OUTER JOIN StudentRegistrationsToDegrees ON CR.StudentRegistrationId = StudentRegistrationsToDegrees.StudentRegistrationId WHERE Best = Grade GROUP BY StudentId HAVING COUNT(StudentId) >= %1% ORDER BY StudentId;
SELECT 0;
WITH StudentCount AS (SELECT CourseOfferId, COUNT(CourseOfferId) as SC FROM CourseRegistrations	GROUP BY CourseRegistrations.CourseOfferId), AssistantCount AS (SELECT CourseOfferId, COUNT(CourseOfferId) as AC FROM StudentAssistants	GROUP BY StudentAssistants.CourseOfferId) SELECT CourseName, Year, Quartile FROM Courses, CourseOffers, StudentCount, AssistantCount WHERE Courses.CourseId = CourseOffers.CourseId AND CourseOffers.CourseOfferId = StudentCount.CourseOfferId AND CourseOffers.CourseOfferId = AssistantCount.CourseOfferId AND (DIV(StudentCount.SC, AssistantCount.AC) <= 50) ORDER BY CourseOfferId;
