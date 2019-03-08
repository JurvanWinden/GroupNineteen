-- Commands to create all tables needed for our database
-- Degrees table
CREATE UNLOGGED TABLE Degrees (DegreeId INT,Dept VARCHAR(50),DegreeDescription VARCHAR(200),TotalECTS SMALLINT);
-- Students table
CREATE UNLOGGED TABLE Students (StudentId INT,StudentName VARCHAR(50),Address VARCHAR(200),BirthyearStudent SMALLINT,Gender CHAR);
-- Student registrations to degrees table
CREATE UNLOGGED TABLE StudentRegistrationsToDegrees (StudentRegistrationId INT,StudentId INT,DegreeId INT,RegistrationYear INT);
-- Teacher table
CREATE UNLOGGED TABLE Teachers (TeacherId INT,TeacherName VARCHAR(50),Address VARCHAR(200),BirthyearTeacher SMALLINT,Gender CHAR);
-- Courses table
CREATE UNLOGGED TABLE Courses (CourseId INT,CourseName VARCHAR(50),CourseDescription VARCHAR(200),DegreeId INT,ECTS SMALLINT);
-- CourseOffers table
CREATE UNLOGGED TABLE CourseOffers (CourseOfferId INT,CourseId INT,Year SMALLINT,Quartile SMALLINT);
-- TeacherAssignmentsToCourses table
CREATE UNLOGGED TABLE TeacherAssignmentsToCourses (CourseOfferId INT,TeacherId INT);
-- StudentAssistants table
CREATE UNLOGGED TABLE StudentAssistants (CourseOfferId INT,StudentRegistrationId INT);
-- CourseRegistrations table
CREATE UNLOGGED TABLE CourseRegistrations (CourseOfferId INT,StudentRegistrationId INT,Grade SMALLINT);
