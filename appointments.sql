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
    Name VARCHAR(100) UNIQUE NOT NULL,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
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
    Name VARCHAR(80) UNIQUE NOT NULL,
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
    CONSTRAINT uniq_doctor_date_time UNIQUE KEY (DoctorID, Date, Time),
    CONSTRAINT fk_appointment_patient FOREIGN KEY (PatientID) REFERENCES Patient (ID),
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor (ID),
    CONSTRAINT fk_appointment_specialty FOREIGN KEY (SpecialtyID) REFERENCES Specialty (ID),
    CONSTRAINT fk_appointment_office FOREIGN KEY (OfficeID) REFERENCES Office (ID)
);

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
    SELECT o.ID, o.Name, o.Address, o.City, o.State
    FROM Office o
    INNER JOIN Doctor d ON d.OfficeID = o.ID
    GROUP BY o.ID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_availableSpecialties//
CREATE PROCEDURE p_availableSpecialties()
BEGIN
    SELECT s.ID, s.Name, s.Description
    FROM Specialty s
    INNER JOIN DoctorSpecialty ds ON ds.SpecialtyID = s.ID
    GROUP BY s.ID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_officeXspecialty//
CREATE PROCEDURE p_officeXspecialty(IN in_SpecialtyID INT)
BEGIN
    SELECT o.ID, o.Name, o.Address, o.City, o.State
    FROM Office o
    INNER JOIN Doctor d ON o.ID = d.OfficeID
    INNER JOIN DoctorSpecialty ds ON d.ID = ds.DoctorID
    WHERE ds.specialtyID = in_SpecialtyID
    GROUP BY o.ID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_specialtyXoffice//
CREATE PROCEDURE p_specialtyXoffice(in_OfficeID INT)
BEGIN
    SELECT s.ID, s.Name, s.Description
    FROM Specialty s
    INNER JOIN DoctorSpecialty ds ON ds.SpecialtyID = s.ID
    INNER JOIN Doctor d ON d.ID = ds.DoctorID
    WHERE d.OfficeID = in_OfficeID
    GROUP BY s.ID;
END//
DELIMITER ;

DELIMITER //
DROP FUNCTION IF EXISTS f_getDoctor//
CREATE FUNCTION f_getDoctor(in_SpecialtyID INT, in_OfficeID INT)
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE l_exit TINYINT DEFAULT FALSE;
    DECLARE l_DoctorID, l_curDoctorID INT DEFAULT 0;
    DECLARE l_AppointmentsNum, l_curAppointmentsNum INT DEFAULT 2147483647;
    DECLARE c_doctors CURSOR FOR
        SELECT d.ID FROM Doctor d
        INNER JOIN DoctorSpecialty de ON d.ID = de.DoctorID
        WHERE de.SpecialtyID = in_SpecialtyID AND d.OfficeID = in_OfficeID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET l_exit := TRUE;

    OPEN c_doctors;
    loop_doctors: LOOP
        FETCH c_doctors INTO l_curDoctorID;
        IF l_exit THEN
          LEAVE loop_doctors;
        END IF;
        -- Get the doctor with fewer appointments starting now
        SELECT count(1) INTO l_curAppointmentsNum FROM Appointment
            WHERE DoctorID = l_curDoctorID AND timestamp(Date, Time) > current_timestamp();
        IF l_curAppointmentsNum < l_AppointmentsNum THEN
            SET l_AppointmentsNum := l_curAppointmentsNum;
            SET l_DoctorID := l_curDoctorID;
        ELSEIF l_curAppointmentsNum = l_AppointmentsNum THEN
            -- When two doctors have the same number of appointments,
            -- get the doctor with fewer appointments overall
            SELECT DoctorID INTO l_DoctorID FROM Appointment
            WHERE DoctorID IN (l_curDoctorID, l_DoctorID)
            GROUP BY DoctorID ORDER BY count(1) ASC LIMIT 1;
        END IF;
    END LOOP;

    CLOSE c_doctors;
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
    DECLARE l_DoctorID INT;
    DECLARE l_MESSAGE_TEXT VARCHAR(255);

    -- Check if PatientID exists
    IF NOT EXISTS (SELECT 1 FROM Patient WHERE ID = in_PatientID) THEN
        SET l_MESSAGE_TEXT := concat("PatientID '", in_PatientID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_MESSAGE_TEXT;
    END IF;

    -- Check if SpecialtyID exists
    IF NOT EXISTS (SELECT 1 FROM Specialty WHERE ID = in_SpecialtyID) THEN
        SET l_MESSAGE_TEXT := concat("SpecialtyID '", in_SpecialtyID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_MESSAGE_TEXT;
    END IF;

    -- Check if OfficeID exists
    IF NOT EXISTS (SELECT 1 FROM Office WHERE ID = in_OfficeID) THEN
        SET l_MESSAGE_TEXT := concat("OfficeID '", in_OfficeID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_MESSAGE_TEXT;
    END IF;

    SET l_DoctorID = (SELECT f_getDoctor(in_SpecialtyID, in_OfficeID));
    -- Check if DoctorID exists
    IF l_DoctorID IS NULL THEN
        SET l_MESSAGE_TEXT := concat("Doctor in office '", in_OfficeID, "' with specialty '", in_SpecialtyID, "' does not exists.");
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = l_MESSAGE_TEXT;
    END IF;

    -- Insert new appointment
    INSERT INTO Appointment (PatientID, DoctorID, SpecialtyID, OfficeID, ScheduleDate, ScheduleTime, Date, Time)
    VALUES (in_PatientID, l_DoctorID, in_SpecialtyID, in_OfficeID, current_date(), current_time(), in_Date, in_Time);
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_updateAppointment//
CREATE PROCEDURE p_updateAppointment(
    IN in_PatientID INT,
    IN in_AppointmentID INT,
    IN in_Date VARCHAR(25),
    IN in_Time VARCHAR(25)
)
BEGIN
    -- Fill variables if passed empty
    IF in_Date = "" THEN
        SELECT Date INTO in_Date FROM Appointment WHERE ID = in_AppointmentID AND PatientID = in_PatientID;
    END IF;

    -- Fill variables if passed empty
    IF in_Time = "" THEN
        SELECT Time INTO in_Time FROM Appointment WHERE ID = in_AppointmentID AND PatientID = in_PatientID;
    END IF;

    -- Update existing appointment
    UPDATE Appointment SET Date = in_Date, Time = in_Time WHERE ID = in_AppointmentID AND PatientID = in_PatientID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_deleteAppointment//
CREATE PROCEDURE p_deleteAppointment(
    IN in_PatientID INT,
    IN in_AppointmentID INT
)
BEGIN
    -- Delete existing appointment
    DELETE FROM Appointment WHERE ID = in_AppointmentID AND PatientID = in_PatientID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_viewAppointmentsShort//
CREATE PROCEDURE p_viewAppointmentsShort(IN in_PatientID INT)
BEGIN
    SELECT a.ID, a.Date, a.Time FROM Appointment a
    INNER JOIN Patient p ON p.ID = a.PatientID
    WHERE a.PatientID = in_PatientID;
END//
DELIMITER ;

DELIMITER //
DROP PROCEDURE IF EXISTS p_viewAppointments//
CREATE PROCEDURE p_viewAppointments(IN in_PatientID INT)
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
