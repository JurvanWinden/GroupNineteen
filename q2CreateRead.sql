-- Our views
-- approx 1 minute
CREATE MATERIALIZED VIEW PassedCoursesPerStudent AS (
    SELECT StudentId, C.CourseId, Grade, ECTS, C.DegreeId FROM Courses AS C, CourseOffers AS CO, CourseRegistrations AS CR, StudentRegistrationsToDegrees AS SD
    WHERE CO.CourseOfferId = CR.CourseOfferId
    AND SD.StudentRegistrationId = CR.StudentRegistrationId
    AND CO.CourseId = C.CourseId
    AND Grade >= 5
    ORDER BY Year, Quartile, CO.CourseOfferId
);


CREATE MATERIALIZED VIEW CompletedCoursesPerStudentRegistrationId AS (
    SELECT SD.StudentRegistrationId, CO.CourseofferId, Grade, ECTS FROM Courses AS C, CourseOffers AS CO, CourseRegistrations AS CR, StudentRegistrationsToDegrees AS SD
    WHERE CO.CourseOfferId = CR.CourseOfferId
    AND SD.StudentRegistrationId = CR.StudentRegistrationId
    AND CO.CourseId = C.CourseId
    AND Grade >= 5
);

-- approx 1 minute
CREATE MATERIALIZED VIEW StudentGPA AS (
    SELECT StudentId, SUM(ECTS * Grade) / CAST (SUM(ECTS) AS DECIMAL) AS GPA FROM PassedCoursesPerStudent
    GROUP BY StudentId
);

CREATE MATERIALIZED VIEW StudentGPA AS (
    SELECT StudentRegistrationId, SUM(ECTS * Grade) / CAST (SUM(ECTS) AS DECIMAL) AS GPA FROM PassedCoursesPerStudent
    GROUP BY StudentRegistrationId
);
