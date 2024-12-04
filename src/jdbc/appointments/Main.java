package jdbc.appointments;

import java.sql.SQLException;
import java.util.InputMismatchException;
import java.util.Scanner;

public class Main {

    public static Scanner sc;
    public static int patientID = -1;
    private static String patientContact = "";
    public static DBConnector db;

    public static void main(String[] args) {

        sc = new Scanner(System.in);
        db = new DBConnector();

        System.out.println("Welcome to your appointments app!");
        mainMenu();

        sc.close();
        db.close();
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
                choice = sc.nextInt();
            } catch (InputMismatchException e) {
                choice = 0;
            } finally {
                sc.nextLine();
                System.out.println();
            }

            if (choice == 3) {
                patientID = -1;
                return true;
            }

            switch (choice) {
                case 1:
                    try {
                        Patient patient = new Patient();
                        patient.createPatient();
                        patientID = patient.getId();
                        patientContact = Patient.getContact(patientID);
                        return false;
                    } catch (SQLException sqlException) {
                        System.err.println("Error creating patient:");
                        System.err.println(sqlException.getMessage());
                    }
                    break;
                case 2:
                    try {
                        patientID = Patient.getIdFromEmail();
                        patientContact = Patient.getContact(patientID);
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
            System.out.println(patientContact);
            System.out.println("-".repeat(patientContact.length()));
            System.out.println("1) Create appointment");
            System.out.println("2) Update appointment");
            System.out.println("3) Delete appointment");
            System.out.println("4) View Appointments");
            System.out.println("5) Go back.");

            try {
                System.out.print("Choose action: ");
                choice = sc.nextInt();
            } catch (InputMismatchException e) {
                choice = 0;
            } finally {
                sc.nextLine();
                System.out.println();
            }

            if (choice == 5) {
                patientID = -1;
                break;
            }

            switch (choice) {
                case 1:
                    Appointments.createAppointment();
                    break;
                case 2:
                    Appointments.updateAppointment();
                    break;
                case 3:
                    Appointments.deleteAppointment();
                    break;
                case 4:
                    Appointments.viewAppointments();
                    break;
                default:
                    System.err.println("Invalid choice!");
                    break;
            }
        }
    }
}
