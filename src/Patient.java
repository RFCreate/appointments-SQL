import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.util.Scanner;

public class Patient {
    private String name;
    private String lastName1;
    private String lastName2;
    private String email;
    private int phone;
    private String city;

    public Patient(Scanner scanner) {
        try {
            System.out.print("Name: ");
            name = scanner.nextLine();
            System.out.print("First Last Name: ");
            lastName1 = scanner.nextLine();
            System.out.print("Second Last Name: ");
            lastName2 = scanner.nextLine();
            System.out.print("Email: ");
            email = scanner.nextLine();
            System.out.print("Phone: ");
            phone = Integer.parseInt(scanner.nextLine());
            System.out.print("City: ");
            city = scanner.nextLine();
        } catch (NumberFormatException e) {
            scanner.nextLine();
        }
    }

    public Patient(String name, String lastName1, String lastName2, String email, int phone, String city) {
        this.name = name;
        this.lastName1 = lastName1;
        this.lastName2 = lastName2;
        this.email = email;
        this.phone = phone;
        this.city = city;
    }

    public void createPatient() throws SQLException {
        CallableStatement cstmt = Appointments.db.conn.prepareCall("{CALL p_createPatient(?, ?, ?, ?, ?, ?)}");
        cstmt.setString(1, name);
        cstmt.setString(2, lastName1);
        cstmt.setString(3, lastName2);
        cstmt.setString(4, email);
        cstmt.setInt(5, phone);
        cstmt.setString(6, city);
        cstmt.execute();
    }

    public int getID() throws SQLException {
        return getPatientFromEmail(this.email);
    }

    public static int getPatientFromEmail(Scanner scanner) throws SQLException {
        System.out.print("Patient Email: ");
        String email = scanner.nextLine();
        return getPatientFromEmail(email);
    }

    private static int getPatientFromEmail(String email) throws SQLException {
        String query = String.format("SELECT ID FROM Patient WHERE Email = '%s';", email);
        ResultSet rs = Appointments.db.stmt.executeQuery(query);
        if (!rs.next()) {
            throw new SQLException("Patient with email '" + email + "' does not exist");
        }
        return rs.getInt(1);
    }
}
