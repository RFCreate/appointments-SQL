package jdbc.appointments;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

public class Patient {
    private String name;
    private String lastName1;
    private String lastName2;
    private String email;
    private int phone;
    private String city;
    private String state;

    public Patient() {
        try {
            System.out.print("Name: ");
            name = Main.sc.nextLine();
            System.out.print("First Last Name: ");
            lastName1 = Main.sc.nextLine();
            System.out.print("Second Last Name: ");
            lastName2 = Main.sc.nextLine();
            System.out.print("Email: ");
            email = Main.sc.nextLine();
            System.out.print("Phone: ");
            phone = Integer.parseInt(Main.sc.nextLine());
            System.out.print("City: ");
            city = Main.sc.nextLine();
            System.out.print("State: ");
            state = Main.sc.nextLine();
        } catch (NumberFormatException e) {
            Main.sc.nextLine();
        }
    }

    public Patient(String name, String lastName1, String lastName2, String email, int phone, String city, String state) {
        this.name = name;
        this.lastName1 = lastName1;
        this.lastName2 = lastName2;
        this.email = email;
        this.phone = phone;
        this.city = city;
        this.state = state;
    }

    public void createPatient() throws SQLException {
        CallableStatement cstmt = Main.db.conn.prepareCall("{CALL p_createPatient(?, ?, ?, ?, ?, ?)}");
        cstmt.setString(1, name);
        cstmt.setString(2, lastName1);
        cstmt.setString(3, lastName2);
        cstmt.setString(4, email);
        cstmt.setInt(5, phone);
        cstmt.setString(6, city);
        cstmt.setString(7, state);
        cstmt.execute();
    }

    public int getID() throws SQLException {
        return getPatientFromEmail(this.email);
    }

    public static int getPatientFromEmail() throws SQLException {
        System.out.print("Patient Email: ");
        String email = Main.sc.nextLine();
        return getPatientFromEmail(email);
    }

    private static int getPatientFromEmail(String email) throws SQLException {
        String query = String.format("SELECT ID FROM Patient WHERE Email = '%s';", email);
        ResultSet rs = Main.db.stmt.executeQuery(query);
        if (!rs.next())
            throw new SQLException("Patient with email '" + email + "' does not exist.");
        return rs.getInt(1);
    }
}
