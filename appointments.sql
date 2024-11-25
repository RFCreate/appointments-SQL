DROP DATABASE IF EXISTS Appointments;
CREATE DATABASE IF NOT EXISTS Appointments;

USE Appointments;

CREATE TABLE Patient (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    LastName1 VARCHAR(50) NOT NULL,
    LastName2 VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(25) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL
);

CREATE TABLE Office (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    OpeningTime TIME NOT NULL,
    ClosingTime TIME NOT NULL
);

CREATE TABLE Doctor (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    LastName1 VARCHAR(50) NOT NULL,
    LastName2 VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(25) NOT NULL,
    OfficeID INT NOT NULL,
    CONSTRAINT fk_doctor_office FOREIGN KEY (OfficeId) REFERENCES Office (ID)
);

CREATE TABLE Specialty (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Name VARCHAR(80) NOT NULL,
    Description VARCHAR(255)
);

CREATE TABLE DoctorSpecialty (
    DoctorID INT NOT NULL,
    SpecialtyID INT NOT NULL,
    CONSTRAINT pk_doctorspecialty PRIMARY KEY (DoctorID, SpecialtyID),
    CONSTRAINT fk_doctorspecialty_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor (ID),
    CONSTRAINT fk_doctorspecialty_specialty FOREIGN KEY (SpecialtyID) REFERENCES Specialty (ID)
);

CREATE TABLE Appointment (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    SpecialtyID INT NOT NULL,
    OfficeID INT NOT NULL,
    ScheduleDate DATE NOT NULL,
    ScheduleTime TIME NOT NULL,
    Date DATE NOT NULL,
    Time TIME NOT NULL,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (PatientID) REFERENCES Patient (ID),
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor (ID),
    CONSTRAINT fk_appointment_specialty FOREIGN KEY (SpecialtyID) REFERENCES Specialty (ID),
    CONSTRAINT fk_appointment_office FOREIGN KEY (OfficeID) REFERENCES Office (ID)
);

DELIMITER //
DROP PROCEDURE IF EXISTS p_createPatient//
CREATE PROCEDURE p_createPatient(
    IN in_Name VARCHAR(50),
    IN in_LastName1 VARCHAR(50),
    IN in_LastName2 VARCHAR(50),
    IN in_Email VARCHAR(100),
    IN in_Phone VARCHAR(25),
    IN in_City VARCHAR(100),
    IN in_State VARCHAR(100)
)
BEGIN
    INSERT INTO Patient (Name, LastName1, LastName2, Email, Phone, City, State) VALUES
        (in_Name, in_LastName1, in_LastName2, in_Email, in_Phone, in_City, in_State);
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_availableOffices//
CREATE PROCEDURE p_availableOffices()
BEGIN
    SELECT o.ID, o.Address, o.City, o.State, o.Name
    FROM Office o
    INNER JOIN Doctor d ON d.OfficeID = o.ID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_availableSpecialties//
CREATE PROCEDURE p_availableSpecialties()
BEGIN
    SELECT DISTINCT s.ID, s.Name, s.Description
    FROM Specialty s
    INNER JOIN DoctorSpecialty ds ON ds.SpecialtyID = s.ID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_officeXspecialty//
CREATE PROCEDURE p_officeXspecialty(IN in_SpecialtyID INT)
BEGIN
    SELECT o.ID, o.Address, o.City, o.State, o.Name
    FROM Office o
    INNER JOIN Doctor d ON o.ID = d.OfficeID
    INNER JOIN DoctorSpecialty ds ON d.ID = ds.DoctorID
    WHERE ds.specialtyID = in_SpecialtyID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_specialtyXoffice//
CREATE PROCEDURE p_specialtyXoffice(in_OfficeID INT)
BEGIN
    SELECT DISTINCT s.ID, s.Name, s.Description
    FROM Specialty s
    INNER JOIN DoctorSpecialty ds ON ds.SpecialtyID = s.ID
    INNER JOIN Doctor d ON d.ID = ds.DoctorID
    WHERE d.OfficeID = in_OfficeID;
END//
DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS f_getDoctor//
CREATE FUNCTION f_getDoctor(in_SpecialtyID INT, in_OfficeID INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE l_DoctorID INT;
    SELECT d.ID INTO l_DoctorID FROM Doctor d
    INNER JOIN DoctorSpecialty de ON d.ID = de.DoctorID
    WHERE de.SpecialtyID = in_SpecialtyID AND d.OfficeID = in_OfficeID
    LIMIT 1;
    RETURN l_DoctorID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_createAppointment//
CREATE PROCEDURE p_createAppointment(
    IN in_PatientID INT,
    IN in_SpecialtyID INT,
    IN in_OfficeID INT,
    IN in_Date DATE,
    IN in_Time TIME
)
BEGIN
    DECLARE error_message VARCHAR(255);
    DECLARE l_DoctorID INT;

    -- Check if PatientID exists
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE ID = in_PatientID) THEN
        SET error_message := concat("PatientID '", in_PatientID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    -- Check if SpecialtyID exists
    IF NOT EXISTS (SELECT 1 FROM Specialty WHERE ID = in_SpecialtyID) THEN
        SET error_message := concat("SpecialtyID '", in_SpecialtyID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    -- Check if OfficeID exists
    IF NOT EXISTS (SELECT 1 FROM Office WHERE ID = in_OfficeID) THEN
        SET error_message := concat("OfficeID '", in_OfficeID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    SET l_DoctorID = (SELECT f_getDoctor(in_SpecialtyID, in_OfficeID));
    -- Check if DoctorID exists
    IF l_DoctorID IS NULL THEN
        SET error_message := concat("DoctorID '", in_SpecialtyID, "' in office '", in_OfficeID, "' with specialty '", in_SpecialtyID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;

    -- Insert new appointment
    INSERT INTO Appointment (PatientID, DoctorID, SpecialtyID, OfficeID, ScheduleDate, ScheduleTime, Date, Time)
    VALUES (in_PatientID, l_DoctorID, in_SpecialtyID, in_OfficeID, current_date(), current_time(), in_Date, in_Time);
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_viewAppointment//
CREATE PROCEDURE p_viewAppointment(IN in_PatientID INT)
BEGIN
    -- View existing appointment with ID changed for actual values
    SELECT a.ID,
        concat_ws(" ", p.Name, p.LastName1, p.LastName2) AS Patient,
        concat_ws(" ", d.Name, d.LastName1, d.LastName2) AS Doctor,
        s.Name AS Specialty, o.Name AS Office, a.Date, a.Time
    FROM Appointment a
    INNER JOIN Patient p ON p.ID = a.PatientID
    INNER JOIN Doctor d ON d.ID = a.DoctorID
    INNER JOIN Specialty s ON s.ID = a.SpecialtyID
    INNER JOIN Office o ON o.ID = a.OfficeID
    WHERE a.PatientID = in_PatientID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_checkAppointmentID//
CREATE PROCEDURE p_checkAppointmentID(IN in_AppointmentID INT)
BEGIN
    DECLARE error_message VARCHAR(255);
    -- Check if AppointmentID exists
    IF NOT EXISTS (SELECT 1 FROM Appointment WHERE ID = in_AppointmentID) THEN
        SET error_message := concat("AppointmentID '", in_AppointmentID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
    END IF;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_updateAppointment//
CREATE PROCEDURE p_updateAppointment(
    IN in_AppointmentID INT,
    IN in_Date VARCHAR(25),
    IN in_Time VARCHAR(25)
)
BEGIN
    CALL p_checkAppointmentID(in_AppointmentID);
    
    -- Exit if both variables are empty
    IF in_Date = "" AND in_Date = "" THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Both date and time are empty.";
    END IF;

    -- Fill variables if passed empty
    IF in_Date = "" THEN
        SELECT Date INTO in_Date FROM Appointment WHERE ID = in_AppointmentID;
    END IF;

    -- Fill variables if passed empty
    IF in_Time = "" THEN
        SELECT Time INTO in_Time FROM Appointment WHERE ID = in_AppointmentID;
    END IF;

    -- Update existing appointment
    UPDATE Appointment
    SET Date = in_Date, Time = in_Time
    WHERE ID = in_AppointmentID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_deleteAppointment//
CREATE PROCEDURE p_deleteAppointment(IN in_AppointmentID INT)
BEGIN
    CALL p_checkAppointmentID(in_AppointmentID);

    -- Delete existing appointment
    DELETE FROM Appointment WHERE ID = in_AppointmentID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_appointmentPerPatient//
CREATE PROCEDURE p_appointmentPerPatient(IN in_PatientID INT)
BEGIN
    SELECT a.ID, a.Date, a.Time FROM Appointment a
    INNER JOIN Patient p ON p.ID = a.PatientID
    WHERE a.PatientID = in_PatientID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_checkFutureTimestamp//
CREATE PROCEDURE p_checkFutureTimestamp(IN in_Date DATE, IN in_Time TIME)
BEGIN
    IF timestamp(in_Date, in_Time) < current_timestamp() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Appointment date and time is past now.";
    END IF;
END//
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS tr_ins_checkFutureTimestamp//
CREATE TRIGGER tr_ins_checkFutureTimestamp
BEFORE INSERT ON Appointment FOR EACH ROW
BEGIN
    CALL p_checkFutureTimestamp(NEW.Date, NEW.Time);
END//
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS tr_upd_checkFutureTimestamp//
CREATE TRIGGER tr_upd_checkFutureTimestamp
BEFORE UPDATE ON Appointment FOR EACH ROW
BEGIN
    CALL p_checkFutureTimestamp(NEW.Date, NEW.Time);
END//
DELIMITER ;
