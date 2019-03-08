-- Our views
-- approx 1 minute
CREATE MATERIALIZED VIEW PassedCoursesPerStudentRegId AS (
    SELECT SD.StudentRegistrationId, C.CourseId, Grade, ECTS, C.DegreeId FROM Courses AS C, CourseOffers AS CO, CourseRegistrations AS CR, StudentRegistrationsToDegrees AS SD
    WHERE CO.CourseOfferId = CR.CourseOfferId
    AND SD.StudentRegistrationId = CR.StudentRegistrationId
    AND CO.CourseId = C.CourseId
    AND Grade >= 5
    ORDER BY Year, Quartile, CO.CourseOfferId
);

CREATE MATERIALIZED VIEW StudentGPA AS (
    SELECT StudentRegistrationId, SUM(ECTS * Grade) / CAST (SUM(ECTS) AS DECIMAL) AS GPA FROM PassedCoursesPerStudent
    GROUP BY StudentRegistrationId
);

--Nieuwe GPA
CREATE MATERIALIZED VIEW StudentGPA AS (
    SELECT StudentId, SUM(ECTS * Grade) / CAST (SUM(ECTS) AS DECIMAL) AS GPA FROM PassedCoursesPerStudent AS PCS1
	JOIN PassedCoursesPerStudent AS PCS2 ON PCS1.StudentId != PCS2.StudentId
	WHERE PCS1.DegreeId = PCS2.DegreeId
    GROUP BY StudentId
);