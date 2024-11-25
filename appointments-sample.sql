USE Appointments;

INSERT INTO Patient (Name, LastName1, LastName2, Email, Phone, City, State) VALUES
("Michael","Johnson","Williams","michaeljohnson@example.com","+1-212-555-1111","New York","NY"),
("Sarah","Brown","Davis","sarahbrown@example.com","+1-212-555-2222","Brooklyn","NY"),
("James","Smith","Taylor","jamessmith@example.com","+1-212-555-3333","Manhattan","NY"),
("Emily","Jones","Miller","emilyjones@example.com","+1-212-555-4444","Queens","NY"),
("David","Garcia","Martinez","davidgarcia@example.com","+1-212-555-5555","The Bronx","NY");

INSERT INTO Office (Address, City, State, Name, OpeningTime, ClosingTime) VALUES
("123 Health St","New York","NY","HealthFirst Medical","08:00","18:00"),
("456 Wellness Ave","Brooklyn","NY","CarePoint Clinic","09:00","17:00"),
("789 Treatment Blvd","Manhattan","NY","City Health Center","07:00","19:00");

INSERT INTO Doctor (Name, LastName1, LastName2, Email, Phone, OfficeID) VALUES
("John","Doe","Smith","johndoe@example.com","+1-212-555-1234","1"),
("Mary","Johnson","Davis","maryjohnson@example.com","+1-212-555-2345","1"),
("William","Brown","Williams","williambrown@example.com","+1-212-555-3456","1"),
("Emily","Roe","Taylor","emilyroe@example.com","+1-212-555-4567","2"),
("David","White","Martin","davidwhite@example.com","+1-212-555-5678","2"),
("Olivia","Green","Harris","oliviagreen@example.com","+1-212-555-6789","2"),
("Michael","Lee","Clark","michaellee@example.com","+1-212-555-7890","3"),
("Sophia","King","Scott","sophiaking@example.com","+1-212-555-8901","3"),
("James","Adams","Turner","jamesadams@example.com","+1-212-555-9012","3");

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
("9","9");
