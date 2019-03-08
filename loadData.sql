COPY Courses(CourseId, CourseName, CourseDescription, DegreeId, ECTS) FROM '/mnt/ramdisk/tables/Courses.table' DELIMITER ',' CSV HEADER;
COPY CourseOffers(CourseOfferId, CourseId, Year, Quartile) FROM '/mnt/ramdisk/tables/CourseOffers.table' DELIMITER ',' CSV HEADER;
COPY TeacherAssignmentsToCourses(CourseOfferId, TeacherId) FROM '/mnt/ramdisk/tables/TeacherAssignmentsToCourses.table' DELIMITER ',' CSV HEADER;
COPY StudentAssistants(CourseOfferId, StudentRegistrationId) FROM '/mnt/ramdisk/tables/StudentAssistants.table' DELIMITER ',' CSV HEADER;
COPY CourseRegistrations(CourseOfferId, StudentRegistrationId, Grade) FROM '/mnt/ramdisk/tables/CourseRegistrations.table' DELIMITER ',' NULL AS 'null' CSV HEADER;
COPY Degrees(DegreeId, Dept, DegreeDescription, TotalECTS) FROM '/mnt/ramdisk/tables/Degrees.table' DELIMITER ',' CSV HEADER;
COPY Students(StudentId, StudentName, Address, BirthyearStudent, Gender) FROM '/mnt/ramdisk/tables/Students.table' DELIMITER ',' CSV HEADER;
COPY StudentRegistrationsToDegrees(StudentRegistrationId, StudentId, DegreeId, RegistrationYear) FROM '/mnt/ramdisk/tables/StudentRegistrationsToDegrees.table' DELIMITER ',' CSV HEADER;
COPY Teachers(TeacherId, TeacherName, Address, BirthyearTeacher, Gender) FROM '/mnt/ramdisk/tables/Teachers.table' DELIMITER ',' CSV HEADER;
ALTER TABLE Degrees ADD PRIMARY KEY (DegreeId);
ALTER TABLE Students ADD PRIMARY KEY (StudentId);
ALTER TABLE StudentRegistrationsToDegrees ADD PRIMARY KEY (StudentRegistrationId);
ALTER TABLE Teachers ADD PRIMARY KEY (TeacherId);
ALTER TABLE Courses ADD PRIMARY KEY (CourseId);
ALTER TABLE CourseOffers ADD PRIMARY KEY (CourseOfferId);
ALTER TABLE StudentRegistrationsToDegrees ADD FOREIGN KEY (StudentId) REFERENCES Students(StudentId);
ALTER TABLE StudentRegistrationsToDegrees ADD FOREIGN KEY (DegreeId) REFERENCES Degrees(DegreeId);
ALTER TABLE Courses ADD FOREIGN KEY (DegreeId) REFERENCES Degrees(DegreeId);
ALTER TABLE CourseOffers ADD FOREIGN KEY (CourseId) REFERENCES Courses(CourseId);
ALTER TABLE TeacherAssignmentsToCourses ADD FOREIGN KEY (CourseOfferId) REFERENCES CourseOffers(CourseOfferId);
ALTER TABLE TeacherAssignmentsToCourses ADD FOREIGN KEY (TeacherId) REFERENCES Teachers(TeacherId);
ALTER TABLE StudentAssistants ADD FOREIGN KEY (CourseOfferId) REFERENCES CourseOffers(CourseOfferId);
ALTER TABLE StudentAssistants ADD FOREIGN KEY (StudentRegistrationId) REFERENCES StudentRegistrationsToDegrees(StudentRegistrationId);
ALTER TABLE CourseRegistrations ADD FOREIGN KEY (CourseOfferId) REFERENCES CourseOffers(CourseOfferId);
ALTER TABLE CourseRegistrations ADD FOREIGN KEY (StudentRegistrationId) REFERENCES StudentRegistrationsToDegrees(StudentRegistrationId);
ANALYZE VERBOSE;


