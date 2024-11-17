import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnector {

    public Connection conn;
    public Statement stmt;

    public DBConnector() {
        try {
            Properties mysqlProperties = new Properties();
            mysqlProperties.load(new FileInputStream("mysql.properties"));
            final String URL = mysqlProperties.getProperty("url");
            final String USERNAME = mysqlProperties.getProperty("username");
            final String PASSWORD = mysqlProperties.getProperty("password");
            conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            stmt = conn.createStatement();
        } catch (SQLException | IOException e) {
            System.out.println(e);
            System.exit(1);
        }
    }

    public void close() {
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
