USE Appointments;

INSERT INTO Patient (Name, LastName1, LastName2, Email, Phone, City, State) VALUES
("Michael","Johnson","Williams","michaeljohnson@example.com","+1-212-555-1111","New York","NY"),
("Sarah","Brown","Davis","sarahbrown@example.com","+1-212-555-2222","Brooklyn","NY"),
("James","Smith","Taylor","jamessmith@example.com","+1-212-555-3333","Manhattan","NY"),
("Emily","Jones","Miller","emilyjones@example.com","+1-212-555-4444","Queens","NY"),
("David","Garcia","Martinez","davidgarcia@example.com","+1-212-555-5555","The Bronx","NY");

INSERT INTO Office (Name, Address, City, State, OpeningTime, ClosingTime) VALUES
("HealthFirst Medical","123 Health St","New York","NY","08:00","18:00"),
("CarePoint Clinic","456 Wellness Ave","Brooklyn","NY","09:00","17:00"),
("City Health Center","789 Treatment Blvd","Manhattan","NY","07:00","19:00");

INSERT INTO Doctor (Name, LastName1, LastName2, Email, Phone, OfficeID) VALUES
("John","Doe","Smith","johndoe@example.com","+1-212-555-1234","1"),
("Mary","Johnson","Davis","maryjohnson@example.com","+1-212-555-2345","1"),
("William","Brown","Williams","williambrown@example.com","+1-212-555-3456","1"),
("Emily","Roe","Taylor","emilyroe@example.com","+1-212-555-4567","2"),
("David","White","Martin","davidwhite@example.com","+1-212-555-5678","2"),
("Olivia","Green","Harris","oliviagreen@example.com","+1-212-555-6789","2"),
("Michael","Lee","Clark","michaellee@example.com","+1-212-555-7890","3"),
("Sophia","King","Scott","sophiaking@example.com","+1-212-555-8901","3"),
("James","Adams","Turner","jamesadams@example.com","+1-212-555-9012","3"),
("Olivia","Martinez","Lopez","olivia.martinez@example.com","+1 212-555-1122","1"),
("Liam","Garcia","Rodriguez","liam.garcia@example.com","+1 718-555-2233","1"),
("Sophia","Miller","Perez","sophia.miller@example.com","+1 917-555-3344","1"),
("Benjamin","Davis","Clark","benjamin.davis@example.com","+1 212-555-4455","2"),
("Isabella","Wilson","Walker","isabella.wilson@example.com","+1 718-555-5566","2"),
("Noah","Moore","Allen","noah.moore@example.com","+1 917-555-6677","2"),
("Charlotte","Taylor","Young","charlotte.taylor@example.com","+1 212-555-7788","3"),
("Ethan","Anderson","King","ethan.anderson@example.com","+1 718-555-8899","3"),
("Amelia","Thomas","Scott","amelia.thomas@example.com","+1 917-555-9900","3");

INSERT INTO Specialty (Name, Description) VALUES
("Cardiology","Specialized in diagnosing and treating heart conditions and diseases."),
("Neurology","Focused on the diagnosis and treatment of disorders related to the brain, spinal cord, and nervous system."),
("Orthopedics","Concerned with the diagnosis, treatment, and prevention of musculoskeletal system disorders, including bones, joints, and muscles."),
("Dermatology","Focused on the diagnosis and treatment of skin conditions and diseases."),
("Pediatrics","Specializes in the care of infants, children, and adolescents."),
("General Surgery","Involves surgical procedures on the abdomen, digestive tract, and other general medical conditions."),
("Psychiatry","Deals with the diagnosis, treatment, and prevention of mental, emotional, and behavioral disorders."),
("Endocrinology","Specializes in the diagnosis and treatment of hormonal and metabolic disorders, including diabetes and thyroid issues."),
("Obstetrics","Focused on pregnancy, childbirth, and the postpartum period."),
("Gynecology","Deals with the female reproductive system, including the diagnosis and treatment of related conditions.");

INSERT INTO DoctorSpecialty (DoctorID, SpecialtyID) VALUES
("1","1"),
("2","2"),
("3","3"),
("4","4"),
("5","5"),
("6","6"),
("7","7"),
("8","8"),
("9","9"),
("10","1"),
("11","2"),
("12","3"),
("13","4"),
("14","5"),
("15","6"),
("16","7"),
("17","8"),
("18","9");

INSERT INTO Appointment (PatientID, DoctorID, SpecialtyID, OfficeID, ScheduleDate, ScheduleTime, Date, Time) VALUES
("1","1","1","1","2024-11-21","11:00:35","2124-11-21","11:30:00"),
("1","2","2","1","2024-11-22","12:00:35","2124-11-22","12:30:00"),
("2","3","3","1","2024-11-23","13:00:35","2124-11-23","13:30:00"),
("2","4","4","2","2024-11-24","14:00:35","2124-11-24","14:30:00"),
("3","5","5","2","2024-11-25","15:00:35","2124-11-25","15:30:00"),
("3","6","6","2","2024-11-26","16:00:35","2124-11-26","16:30:00"),
("4","7","7","3","2024-11-27","17:00:35","2124-11-27","17:30:00"),
("4","8","8","3","2024-11-28","18:00:35","2124-11-28","18:30:00"),
("5","9","9","3","2024-11-29","19:00:35","2124-11-29","19:30:00");
