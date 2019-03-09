-- Our views
-- approx 1 minute
CREATE MATERIALIZED VIEW PassedCoursesPerStudentRegId AS (
    SELECT SD.StudentRegistrationId, C.CourseId, Grade, ECTS, C.DegreeId FROM Courses AS C, CourseOffers AS CO, CourseRegistrations AS CR, StudentRegistrationsToDegrees AS SD
    WHERE CO.CourseOfferId = CR.CourseOfferId
    AND SD.StudentRegistrationId = CR.StudentRegistrationId
    AND CO.CourseId = C.CourseId
    AND C.DegreeId = SD.DegreeId
    AND Grade >= 5
    AND Grade IS NOT NULL
    ORDER BY Year, Quartile, CO.CourseOfferId
);

CREATE MATERIALIZED VIEW FailedCoursesPerStudentRegId AS (
    SELECT CR.StudentRegistrationId, CR.Grade, CourseOfferId FROM CourseRegistrations AS CR
    LEFT OUTER JOIN PassedCoursesPerStudentRegId ON PassedCoursesPerStudentRegId.StudentRegistrationId = CR.StudentRegistrationId
    WHERE PassedCoursesPerStudentRegId.StudentRegistrationId IS NULL
    AND CR.Grade IS NOT NULL
);

CREATE MATERIALIZED VIEW SumECTS AS (
    SELECT StudentRegistrationId, SUM(ECTS) AS SumECTS FROM PassedCoursesPerStudentRegId, Degrees
    WHERE Degrees.DegreeId = PassedCoursesPerStudentRegId.DegreeId
    GROUP BY StudentRegistrationId
);

CREATE MATERIALIZED VIEW StudentGPA AS (
    SELECT StudentRegistrationId, SUM(ECTS * Grade) / CAST (SUM(ECTS) AS DECIMAL) AS GPA FROM PassedCoursesPerStudentRegId
    GROUP BY StudentRegistrationId ORDER BY StudentRegistrationId
);

