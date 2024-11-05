DROP DATABASE IF EXISTS Appointments;
CREATE DATABASE IF NOT EXISTS Appointments;

USE Appointments;

CREATE TABLE Patient (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    LastName1 VARCHAR(50) NOT NULL,
    LastName2 VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone BIGINT NOT NULL,
    City VARCHAR(100) NOT NULL
);
SELECT ID FROM Patient WHERE Email = 't';
CREATE TABLE Office (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Adress VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Name VARCHAR(100) NOT NULL,
    OpeningTime TIME NOT NULL,
    ClosingTime TIME NOT NULL
);

CREATE TABLE Doctor (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    LastName1 VARCHAR(50) NOT NULL,
    LastName2 VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone BIGINT NOT NULL,
    OfficeID INT NOT NULL,
    CONSTRAINT fk_doctor_office FOREIGN KEY (OfficeId) REFERENCES Office (ID)
);

CREATE TABLE Specialty (
    ID INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    Name VARCHAR(80) NOT NULL
);

CREATE TABLE DoctorSpecialty (
    DoctorID INT NOT NULL,
    SpecialtyID INT NOT NULL,
    Description VARCHAR(255),
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
    ScheduleTime TIME NOT NULL,
    ScheduleDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    AppointmentDate DATE NOT NULL,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (PatientID) REFERENCES Patient (ID),
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (DoctorID) REFERENCES Doctor (ID),
    CONSTRAINT fk_appointment_specialty FOREIGN KEY (SpecialtyID) REFERENCES Specialty (ID),
    CONSTRAINT fk_appointment_office FOREIGN KEY (OfficeID) REFERENCES Office (ID)
);

