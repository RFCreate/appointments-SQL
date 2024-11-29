package jdbc.appointments;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.ResultSet;

public class Patient {
    private String name;
    private String lastName1;
    private String lastName2;
    private String email;
    private String phone;
    private String city;
    private String state;

    public Patient() {
        System.out.print("Name: ");
        name = Main.sc.nextLine();
        System.out.print("First Last Name: ");
        lastName1 = Main.sc.nextLine();
        System.out.print("Second Last Name: ");
        lastName2 = Main.sc.nextLine();
        System.out.print("Email: ");
        email = Main.sc.nextLine();
        System.out.print("Phone: ");
        phone = Main.sc.nextLine();
        System.out.print("City: ");
        city = Main.sc.nextLine();
        System.out.print("State: ");
        state = Main.sc.nextLine();
    }

    public void createPatient() throws SQLException {
        CallableStatement cstmt = Main.db.conn.prepareCall("{CALL p_createPatient(?, ?, ?, ?, ?, ?, ?)}");
        cstmt.setString(1, name);
        cstmt.setString(2, lastName1);
        cstmt.setString(3, lastName2);
        cstmt.setString(4, email);
        cstmt.setString(5, phone);
        cstmt.setString(6, city);
        cstmt.setString(7, state);
        cstmt.execute();
    }

    public int getId() throws SQLException {
        return getIdFromEmail(this.email);
    }

    public static int getIdFromEmail() throws SQLException {
        System.out.print("Patient Email: ");
        String email = Main.sc.nextLine();
        return getIdFromEmail(email);
    }

    private static int getIdFromEmail(String email) throws SQLException {
        String query = String.format("SELECT ID FROM Patient WHERE Email = '%s'", email);
        ResultSet rs = Main.db.stmt.executeQuery(query);
        if (!rs.next())
            throw new SQLException("Patient with email '" + email + "' does not exist.");
        return rs.getInt(1);
    }

    public static String getEmailFromId(int id) throws SQLException {
        String query = String.format("SELECT Email FROM Patient WHERE ID = '%s'", id);
        ResultSet rs = Main.db.stmt.executeQuery(query);
        if (!rs.next())
            throw new SQLException("Patient with ID '" + id + "' does not exist.");
        return rs.getString(1);
    }
}
