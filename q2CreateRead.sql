-- Our views
-- approx 1 minute
CREATE INDEX idx_Grade ON CourseRegistrations(StudentRegistrationId, Grade) WHERE Grade >= 5 AND Grade IS NOT NULL;

CREATE MATERIALIZED VIEW CompletedDegree AS (
    SELECT S.StudentRegistrationId FROM StudentRegistrationsToDegrees AS SD, Degrees AS D, SumECTS AS S
    WHERE S.StudentRegistrationId = SD.StudentRegistrationId
    AND SD.DegreeId = D.DegreeId
    AND S.sumECTS >= TotalECTS
);

CREATE MATERIALIZED VIEW StudentCountPerCourse AS (
SELECT CO.CourseId, COUNT(CO.CourseId) AS SC FROM CourseOffers AS CO LEFT OUTER JOIN CourseRegistrations AS CR ON CO.CourseOfferId = CR.CourseOfferId
WHERE Grade IS NOT NULL GROUP BY CO.CourseId
);

CREATE MATERIALIZED VIEW SumECTS AS (
    WITH PassedCoursesPerStudentRegId AS (
         SELECT SD.StudentRegistrationId, Grade, ECTS, SD.DegreeId FROM Courses AS C, CourseOffers AS CO, CourseRegistrations AS CR, StudentRegistrationsToDegrees AS SD
         WHERE CO.CourseOfferId = CR.CourseOfferId
         AND SD.StudentRegistrationId = CR.StudentRegistrationId
         AND CO.CourseId = C.CourseId
         AND Grade >= 5
         AND Grade IS NOT NULL
    )
    SELECT StudentRegistrationId, SUM(ECTS) AS SumECTS FROM PassedCoursesPerStudentRegId, Degrees
    WHERE Degrees.DegreeId = PassedCoursesPerStudentRegId.DegreeId
    GROUP BY StudentRegistrationId
);

CREATE MATERIALIZED VIEW StudentGPA AS (
    SELECT P.StudentRegistrationId, ROUND( SUM(ECTS * Grade) / CAST (SUM(ECTS) AS DECIMAL), 1 ) AS GPA FROM PassedCoursesPerStudentRegId AS P, StudentRegistrationsToDegrees AS SD
    WHERE P.StudentRegistrationId = SD.StudentRegistrationId
    GROUP BY P.StudentRegistrationId ORDER BY P.StudentRegistrationId
);

