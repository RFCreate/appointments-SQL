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
        List<Integer> validIds = new ArrayList<>();
        try {
            rs = Main.db.stmt.executeQuery("CALL p_availableSpecialties()");
            System.out.println();
            System.out.println("Available Specialties");
            System.out.println("---------------------");

            validIds.clear();
            while (rs.next()) {
                validIds.add(rs.getInt(1));
                System.out.println("%s) %s:%s".formatted(
                        validIds.size(), rs.getString(2), rs.getString(3)));
            }
            System.out.print("Enter Specialty ID: ");
            int specialtyID = Main.sc.nextInt();
            Main.sc.nextLine();
            try {
                specialtyID = validIds.get(specialtyID - 1);
            } catch (IndexOutOfBoundsException e) {
                throw new SQLException("Specialty ID not in list!");
            }

            rs = Main.db.stmt.executeQuery("CALL p_officeXspecialty(%s)".formatted(specialtyID));
            System.out.println();
            System.out.println("Available Offices for specialty");
            System.out.println("-------------------------------");

            validIds.clear();
            while (rs.next()) {
                validIds.add(rs.getInt(1));
                System.out.println("%s) %s (%s, %s, %s)".formatted(
                        validIds.size(), rs.getString(2), rs.getString(3), rs.getString(4), rs.getString(5)));
            }
            System.out.print("Enter Office ID: ");
            int officeID = Main.sc.nextInt();
            Main.sc.nextLine();
            try {
                officeID = validIds.get(officeID - 1);
            } catch (IndexOutOfBoundsException e) {
                throw new SQLException("Specialty ID not in list!");
            }

            System.out.println();
            System.out.print("Appointment Date (YYYY-MM-DD): ");
            String date = Main.sc.nextLine();
            System.out.print("Appointment Time (hh:mm): ");
            String time = Main.sc.nextLine();

            CallableStatement cstmt = Main.db.conn.prepareCall("{CALL p_createAppointment(?, ?, ?, ?, ?)}");
            cstmt.setInt(1, Main.patientID);
            cstmt.setInt(2, specialtyID);
            cstmt.setInt(3, officeID);
            cstmt.setString(4, date);
            cstmt.setString(5, time);
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

    private static void viewAppointmentsShort() throws SQLException {
        ResultSet rs = Main.db.stmt.executeQuery("CALL p_viewAppointmentsShort(%s)".formatted(Main.patientID));
        if (!rs.next())
            throw new SQLException("Patient does not have appointments.");
        String appointment = "";
        do {
            appointment = "ID:%s | Date:%s | Time:%s".formatted(
                    rs.getInt(1), rs.getString(2), rs.getString(3));
            System.out.println(appointment);
        } while (rs.next());
        System.out.println("-".repeat(appointment.length()));
    }

    private static int getAppointmentId() throws SQLException {
        System.out.print("Enter Appointment ID: ");
        int appointmentID = Main.sc.nextInt();
        Main.sc.nextLine();
        ResultSet rs = Main.db.stmt.executeQuery(
                "SELECT ID FROM Appointment WHERE ID = %s AND PatientID = %s"
                        .formatted(appointmentID, Main.patientID));
        if (!rs.next())
            throw new SQLException("Patient has no appointment with ID '" + appointmentID + "'.");
        return appointmentID;
    }

    public static void updateAppointment() {
        try {
            viewAppointmentsShort();
            int appointmentID = getAppointmentId();

            System.out.println("Leave it blank to not modify.");
            System.out.print("New Appointment Date (YYYY-MM-DD): ");
            String date = Main.sc.nextLine();
            System.out.print("New Appointment Time (hh:mm): ");
            String time = Main.sc.nextLine();

            CallableStatement cstmt = Main.db.conn.prepareCall("{CALL p_updateAppointment(?, ?, ?, ?)}");
            cstmt.setInt(1, Main.patientID);
            cstmt.setInt(2, appointmentID);
            cstmt.setString(3, date);
            cstmt.setString(4, time);
            cstmt.execute();
            System.out.println("Success updating appointment!");

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
            viewAppointmentsShort();
            int appointmentID = getAppointmentId();

            CallableStatement cstmt = Main.db.conn.prepareCall("{CALL p_deleteAppointment(?, ?)}");
            cstmt.setInt(1, Main.patientID);
            cstmt.setInt(2, appointmentID);
            cstmt.execute();
            System.out.println("Success deleting appointment!");

        } catch (InputMismatchException e) {
            System.err.println("Invalid ID!");
            Main.sc.nextLine();
        } catch (SQLException sqlException) {
            System.err.println("Error deleting appointment:");
            System.err.println(sqlException.getMessage());
        }
    }

    public static void viewAppointments() {
        try {
            ResultSet rs = Main.db.stmt.executeQuery("CALL p_viewAppointments(%s)".formatted(Main.patientID));
            ResultSetMetaData rsmd = rs.getMetaData();
            if (!rs.next())
                throw new SQLException("Patient does not have appointments.");
            do {
                System.out.println("---");
                for (int i = 1; i <= rsmd.getColumnCount(); i++) {
                    System.out.println("%s: %s".formatted(rsmd.getColumnLabel(i), rs.getObject(i)));
                }
            } while (rs.next());
            System.out.println("---");
        } catch (SQLException sqlException) {
            System.err.println("Error viewing appointment:");
            System.err.println(sqlException.getMessage());
        }
    }
}
