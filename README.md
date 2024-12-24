# Medical Appointments

This project is a demo for testing development of a MySQL database based on medical appointments and a Java based TUI (text user interface) for user intercation using the JDBC (Java Database Connector) to connect to the appointments database.

## Usage

1. Clone the repository.

```
git clone https://github.com/shyguyCreate/appointmentsSQL.git
```

2. Create the appointments database.

```
mysql -u USER -p < appointments.sql
```

3. (Optional) Add sample information to the database.

```
mysql -u USER -p < appointments-sample.sql
```

4. Create `mysql.properties` file with your MySQL information. This file should be in the current directory when you run the app. Check `mysql-sample.properties` to fill it correctly.

5. Create `lib` folder and inside it download the [MySQL JDBC](https://dev.mysql.com/downloads/connector/j/) compatible with your MySQL version.

6. Compile Java source code in `bin` folder.

```
javac -d bin src/jdbc/appointments/*.java
```

7. Run Java app.

```
java -cp bin:lib/mysql-connector-j-9.0.0.jar jdbc.appointments.Main
```
