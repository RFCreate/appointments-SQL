import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.InputMismatchException;
import java.util.Scanner;

public class Appointments {

    private static Scanner scanner;
    private static int patientID = -1;
    public static DBConnector db;

    public static void main(String[] args) {

        scanner = new Scanner(System.in);
        db = new DBConnector();

        System.out.println("Welcome to your appointments app!");

        mainMenu();
        scanner.close();
        db.finalize();
    }

    private static void mainMenu() {
        boolean exit = false;
        while (!exit) {
            if (patientID == -1) {
                exit = idMenu();
            } else {
                appointmentMenu();
            }
        }
    }

    private static boolean idMenu() {
        int choice = 0;
        while (true) {
            System.out.println();
            System.out.println("1) Create new patient");
            System.out.println("2) Use existing email");
            System.out.println("3) Exit.");

            try {
                System.out.print("Choose action: ");
                choice = scanner.nextInt();
            } catch (InputMismatchException e) {
                choice = 0;
            } finally {
                scanner.nextLine();
            }

            if (choice == 3) {
                patientID = -1;
                return true;
            }

            switch (choice) {
                case 1:
                    try {
                        Patient patient = new Patient(scanner);
                        patient.createPatient();
                        patientID = patient.getID();
                        return false;
                    } catch (SQLException sqlException) {
                        System.err.println("Error creating patient:");
                        System.err.println(sqlException.getMessage());
                    }
                    break;
                case 2:
                    try {
                        patientID = Patient.getPatientFromEmail(scanner);
                        return false;
                    } catch (SQLException sqlException) {
                        System.err.println("Error retriving patient:");
                        System.err.println(sqlException.getMessage());
                    }
                    break;
                default:
                    System.err.println("Invalid choice!");
                    break;
            }

        }
    }

    private static void appointmentMenu() {
        int choice = 0;
        while (true) {
            System.out.println();
            System.out.println("ID: " + patientID);
            System.out.println("1) Create appointment");
            System.out.println("2) View Appointment");
            System.out.println("3) Update appointment");
            System.out.println("4) Delete appointment");
            System.out.println("5) Go back.");

            try {
                System.out.print("Choose action: ");
                choice = scanner.nextInt();
            } catch (InputMismatchException e) {
                choice = 0;
            } finally {
                scanner.nextLine();
            }

            if (choice == 5) {
                patientID = -1;
                break;
            }

            switch (choice) {
                case 1:
                    createAppointment();
                    break;
                case 2:
                    viewAppointment();
                    break;
                case 3:
                    updateAppointment();
                    break;
                case 4:
                    deleteAppointment();
                    break;
                default:
                    System.err.println("Invalid choice!");
                    break;
            }
        }
    }

    private static void createAppointment() {
        ResultSet rs = null;
        try {
            rs = db.stmt.executeQuery("CALL p_availableSpecialties();");
            System.out.println();
            System.out.println("Available Specialties");
            System.out.println("---------------------");

            while (rs.next()) {
                System.out.print("ID:" + rs.getInt(1));
                System.out.print(", Name:" + rs.getString(2));
                System.out.print(", Description:" + rs.getString(3));
            }
            System.out.println();
            System.out.print("Enter Specialty ID: ");
            int specialtyID = scanner.nextInt();
            scanner.nextLine();

            rs = db.stmt.executeQuery("CALL p_officeXspecialty(%s);".formatted(specialtyID));
            System.out.println();
            System.out.println("Available Offices for specialty");
            System.out.println("-------------------------------");

            while (rs.next()) {
                System.out.print("ID:" + rs.getInt(1));
                System.out.print(", Name:" + rs.getString(2));
                System.out.print(", Adress:" + rs.getString(3));
                System.out.print(", City:" + rs.getString(4));
            }
            System.out.println();
            System.out.print("Office ID: ");
            int officeID = scanner.nextInt();
            scanner.nextLine();

            System.out.print("Appointment Time (hh:mm): ");
            String time = scanner.nextLine();
            System.out.print("Appointment Date (YYYY-MM-DD): ");
            String date = scanner.nextLine();

            CallableStatement cstmt = db.conn.prepareCall("{CALL p_createAppointment(?, ?, ?, ?, ?)}");
            cstmt.setInt(1, patientID);
            cstmt.setInt(2, specialtyID);
            cstmt.setInt(3, officeID);
            cstmt.setString(4, time);
            cstmt.setString(5, date);
            cstmt.execute();
            System.out.println("Success creating appointment!");

        } catch (InputMismatchException e) {
            System.err.println("Invalid ID!");
            scanner.nextLine();
        } catch (SQLException sqlException) {
            System.err.println("Error creating appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    private static void viewAppointment() {
        try {

        } catch (SQLException sqlException) {
            System.err.println("Error viewing appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    private static void viewAppointmentsShort() {
        try {
            ResultSet rs = db.stmt.executeQuery("CALL p_appointmentPerPatient(%s)".formatted(patientID));
            while (rs.next()) {
                System.out.print("ID:" + rs.getInt(1));
                System.out.print(", Time:" + rs.getString(3));
                System.out.print(", Date:" + rs.getString(2));
            }
        } catch (SQLException sqlException) {
            System.err.println("Error viewing appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    private static void updateAppointment() {
        try {
            System.out.println();
            viewAppointmentsShort();
            System.out.println();
            System.out.print("Enter Appointment ID: ");
            int appointmentID = scanner.nextInt();
            scanner.nextLine();

            System.out.println("Leave blank to not modify.");
            System.out.print("New Appointment Time (hh:mm): ");
            String time = scanner.nextLine();
            System.out.print("New Appointment Date (YYYY-MM-DD): ");
            String date = scanner.nextLine();

            CallableStatement stmt = db.conn.prepareCall("{CALL p_updateAppointment(?, ?, ?)}");
            stmt.setInt(1, appointmentID);
            stmt.setString(2, time);
            stmt.setString(3, date);
            stmt.execute();

        } catch (InputMismatchException e) {
            System.err.println("Invalid ID!");
            scanner.nextLine();
        } catch (SQLException sqlException) {
            System.err.println("Error updating appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    private static void deleteAppointment() {
        try {
            System.out.println();
            viewAppointment();
            System.out.println();
            System.out.print("Enter Appointment ID: ");
            int appointmentID = scanner.nextInt();
            scanner.nextLine();

            db.stmt.executeQuery("CALL p_deleteAppointment(%s);".formatted(appointmentID));

        } catch (InputMismatchException e) {
            System.err.println("Invalid ID!");
            scanner.nextLine();
        } catch (SQLException sqlException) {
            System.err.println("Error deleting appointment:");
            System.err.println(sqlException.getMessage());
        }
    }
}
