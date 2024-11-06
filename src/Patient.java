import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.util.Scanner;

public class Patient {
    private String name;
    private String lastName1;
    private String lastName2;
    private String email;
    private String phone;
    private String city;

    public Patient(Scanner scanner) {
        System.out.print("Name: ");
        name = scanner.nextLine();
        System.out.print("First Last Name: ");
        lastName1 = scanner.nextLine();
        System.out.print("Second Last Name: ");
        lastName2 = scanner.nextLine();
        System.out.print("Email: ");
        email = scanner.nextLine();
        System.out.print("Phone: ");
        phone = scanner.nextLine();
        System.out.print("City: ");
        city = scanner.nextLine();
    }

    public Patient(String name, String lastName1, String lastName2, String email, String phone, String city) {
        this.name = name;
        this.lastName1 = lastName1;
        this.lastName2 = lastName2;
        this.email = email;
        this.phone = phone;
        this.city = city;
    }

    public void createPatient() throws SQLException {
        CallableStatement stmt = Appointments.db.conn.prepareCall("{CALL p_createPatient(?, ?, ?, ?, ?, ?)}");
        stmt.setString(1, name);
        stmt.setString(2, lastName1);
        stmt.setString(3, lastName2);
        stmt.setString(4, email);
        stmt.setString(5, phone);
        stmt.setString(6, city);
        stmt.execute();
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
        ResultSet result = Appointments.db.stmt.executeQuery(query);
        if (!result.next()) {
            throw new SQLException("Patient with email '" + email + "' does not exist");
        }
        return result.getInt(1);
    }
}
