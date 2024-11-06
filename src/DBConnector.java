import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.SQLException;

public class DBConnector {

    private static final String URL = "jdbc:mysql://localhost:3306/Appointments";
    private static final String USER = "root";
    private static final String PASSWORD = "mysql";

    public Connection conn;
    public Statement stmt;

    public DBConnector() {
        try {
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            stmt = conn.createStatement();
        } catch (SQLException sqlException) {
            System.err.println(sqlException);
            System.exit(1);
        }
    }

    public void finalize() {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException sqlException) {
            }
            conn = null;
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException sqlException) {
            }
            stmt = null;
        }
    }
}
