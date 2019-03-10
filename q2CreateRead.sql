-- Our views
-- approx 1 minute
CREATE MATERIALIZED VIEW PassedCoursesPerStudentRegId AS (
    SELECT SD.StudentRegistrationId, SD.DegreeId, CO.CourseOfferId, Year, Quartile, CourseName, Grade, ECTS FROM Courses AS C, CourseOffers AS CO, CourseRegistrations AS CR, StudentRegistrationsToDegrees AS SD
    WHERE CO.CourseOfferId = CR.CourseOfferId
    AND SD.StudentRegistrationId = CR.StudentRegistrationId
    AND CO.CourseId = C.CourseId
    AND Grade >= 5
    AND Grade IS NOT NULL
    ORDER BY Year, Quartile, CourseOfferId
);


CREATE MATERIALIZED VIEW SumECTS AS (
    SELECT StudentRegistrationId, SUM(ECTS) AS SumECTS FROM PassedCoursesPerStudentRegId, Degrees
    WHERE Degrees.DegreeId = PassedCoursesPerStudentRegId.DegreeId
    GROUP BY StudentRegistrationId
);

CREATE MATERIALIZED VIEW StudentGPA AS (
    SELECT P.StudentRegistrationId, SD.DegreeId, SUM(ECTS * Grade) / CAST (SUM(ECTS) AS DECIMAL) AS GPA FROM PassedCoursesPerStudentRegId AS P, StudentRegistrationsToDegrees AS SD
    WHERE P.StudentRegistrationId = SD.StudentRegistrationId
    GROUP BY P.StudentRegistrationId, SD.DegreeId ORDER BY P.StudentRegistrationId
);

