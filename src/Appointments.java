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
        try {

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

    private static void updateAppointment() {
        try {

        } catch (SQLException sqlException) {
            System.err.println("Error updating appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    private static void deleteAppointment() {
        try {

        } catch (SQLException sqlException) {
            System.err.println("Error deleting appointment:");
            System.err.println(sqlException.getMessage());
        }
    }
}
