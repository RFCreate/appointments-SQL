package jdbc.appointments;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.InputMismatchException;
import java.util.List;

public class Appointments {

    public static void createAppointment() {
        ResultSet rs = null;
        try {
            rs = Main.db.stmt.executeQuery("CALL p_availableSpecialties();");
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
            int specialtyID = Main.sc.nextInt();
            Main.sc.nextLine();

            rs = Main.db.stmt.executeQuery("CALL p_officeXspecialty(%s);".formatted(specialtyID));
            System.out.println();
            System.out.println("Available Offices for specialty");
            System.out.println("-------------------------------");

            while (rs.next()) {
                System.out.print("ID:" + rs.getInt(1));
                System.out.print(", Name:" + rs.getString(2));
                System.out.print(", Address:" + rs.getString(3));
                System.out.print(", City:" + rs.getString(4));
                System.out.print(", State:" + rs.getString(5));
            }
            System.out.println();
            System.out.print("Office ID: ");
            int officeID = Main.sc.nextInt();
            Main.sc.nextLine();

            System.out.print("Appointment Time (hh:mm): ");
            String time = Main.sc.nextLine();
            System.out.print("Appointment Date (YYYY-MM-DD): ");
            String date = Main.sc.nextLine();

            CallableStatement cstmt = Main.db.conn.prepareCall("{CALL p_createAppointment(?, ?, ?, ?, ?)}");
            cstmt.setInt(1, Main.patientID);
            cstmt.setInt(2, specialtyID);
            cstmt.setInt(3, officeID);
            cstmt.setString(4, time);
            cstmt.setString(5, date);
            cstmt.execute();
            System.out.println("Success creating appointment!");

        } catch (InputMismatchException e) {
            System.err.println("Invalid ID!");
            Main.sc.nextLine();
        } catch (SQLException sqlException) {
            System.err.println("Error creating appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    public static void viewAppointment() {
        try {
            ResultSet rs = Main.db.stmt.executeQuery("CALL p_viewAppointment(%s);".formatted(Main.patientID));
            ResultSetMetaData rsmd = rs.getMetaData();
            while (rs.next()) {
                System.out.println("{");
                for (int i = 0; i < rsmd.getColumnCount(); i++) {
                    System.out.println("\t%s: %s".formatted(rsmd.getColumnName(i), rs.getObject(i)));
                }
                System.out.println("}");
            }

        } catch (SQLException sqlException) {
            System.err.println("Error viewing appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    private static List<Integer> viewAppointmentsShort() throws SQLException {
        List<Integer> appointments = new ArrayList<>();
        ResultSet rs = Main.db.stmt.executeQuery("CALL p_appointmentPerPatient(%s)".formatted(Main.patientID));
        if (!rs.next())
            throw new SQLException("Patient '" + Main.patientID + "' does not have appointments.");
        do {
            appointments.add(rs.getInt(1));
            System.out.print("ID:" + rs.getInt(1));
            System.out.print(", Time:" + rs.getString(3));
            System.out.print(", Date:" + rs.getString(2));
        } while (rs.next());
        return appointments;
    }

    private static int checkAppointmentFromPatient() throws SQLException {
        System.out.println();
        List<Integer> appointments = viewAppointmentsShort();
        System.out.println();
        System.out.print("Enter Appointment ID: ");
        int appointmentID = Main.sc.nextInt();
        Main.sc.nextLine();
        if (!appointments.contains(appointmentID))
            throw new SQLException("Patient does not have AppointmentID '" + appointmentID + "'.");
        return appointmentID;
    }

    public static void updateAppointment() {
        try {
            int appointmentID = checkAppointmentFromPatient();

            System.out.println("Leave blank to not modify.");
            System.out.print("New Appointment Time (hh:mm): ");
            String time = Main.sc.nextLine();
            System.out.print("New Appointment Date (YYYY-MM-DD): ");
            String date = Main.sc.nextLine();

            CallableStatement stmt = Main.db.conn.prepareCall("{CALL p_updateAppointment(?, ?, ?)}");
            stmt.setInt(1, appointmentID);
            stmt.setString(2, time);
            stmt.setString(3, date);
            stmt.execute();

        } catch (InputMismatchException e) {
            System.err.println("Invalid ID!");
            Main.sc.nextLine();
        } catch (SQLException sqlException) {
            System.err.println("Error updating appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    public static void deleteAppointment() {
        try {
            int appointmentID = checkAppointmentFromPatient();

            Main.db.stmt.executeQuery("CALL p_deleteAppointment(%s);".formatted(appointmentID));

        } catch (InputMismatchException e) {
            System.err.println("Invalid ID!");
            Main.sc.nextLine();
        } catch (SQLException sqlException) {
            System.err.println("Error deleting appointment:");
            System.err.println(sqlException.getMessage());
        }
    }
}
