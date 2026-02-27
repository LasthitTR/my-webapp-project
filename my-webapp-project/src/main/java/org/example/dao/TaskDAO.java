package org.example.dao;

import org.example.model.Task;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Görev verisi için DAO sınıfı.
 */
public class TaskDAO {
    /** Varsayılan veritabanı dosya adı. */
    private static final String DB_FILENAME = "todo.db";
    /** Birinci kolon indeksi. */
    private static final int FIRST_COLUMN = 1;
    /** İkinci kolon indeksi. */
    private static final int SECOND_COLUMN = 2;
    /** Üçüncü kolon indeksi. */
    private static final int THIRD_COLUMN = 3;

    /** Veritabanı bağlantı URL'i. */
    private final String dbUrl;

    /**
     * Varsayılan yapıcı.
     */
    public TaskDAO() {
        this.dbUrl = resolveDbUrl();
        loadDriver();
        initializeDatabase();
    }

    /**
     * @return veritabanı bağlantı URL'i
     */
    public String getDbUrl() {
        return dbUrl;
    }

    private String resolveDbUrl() {
        String configuredPath = System.getProperty("task.db.path");
        if (configuredPath == null || configuredPath.trim().isEmpty()) {
            configuredPath = DB_FILENAME;
        }

        Path dbPath = Paths.get(configuredPath).toAbsolutePath().normalize();
        return "jdbc:sqlite:" + dbPath;
    }

    private void loadDriver() {
        try {
            Class.forName("org.sqlite.JDBC");
        } catch (ClassNotFoundException exception) {
            throw new RuntimeException(
                    "Failed to load SQLite JDBC driver",
                    exception
            );
        }
    }

    private void initializeDatabase() {
        String sql = "CREATE TABLE IF NOT EXISTS tasks ("
                + "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                + "title TEXT NOT NULL,"
                + "completed INTEGER NOT NULL DEFAULT 0"
                + ")";

        try (Connection connection = DriverManager.getConnection(dbUrl);
             Statement statement = connection.createStatement()) {
            statement.execute(sql);
        } catch (SQLException exception) {
            throw new RuntimeException(
                    "Failed to initialize database",
                    exception
            );
        }
    }

    /**
     * @return tüm görevler
     */
    public List<Task> getAllTasks() {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT id, title, completed FROM tasks ORDER BY id";

        try (Connection connection = DriverManager.getConnection(dbUrl);
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {

            while (resultSet.next()) {
                tasks.add(new Task(
                        resultSet.getInt("id"),
                        resultSet.getString("title"),
                        resultSet.getInt("completed") == 1
                ));
            }
        } catch (SQLException exception) {
            throw new RuntimeException(
                    "Failed to fetch tasks",
                    exception
            );
        }

        return tasks;
    }

    /**
     * @param id görev kimliği
     * @return görev bulunursa görev, aksi halde null
     */
    public Task getTaskById(final int id) {
        String sql = "SELECT id, title, completed FROM tasks WHERE id = ?";

        try (Connection connection = DriverManager.getConnection(dbUrl);
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, id);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return new Task(
                            resultSet.getInt("id"),
                            resultSet.getString("title"),
                            resultSet.getInt("completed") == 1
                    );
                }
            }
        } catch (SQLException exception) {
            throw new RuntimeException("Failed to fetch task", exception);
        }

        return null;
    }

    /**
     * @param task kaydedilecek görev
     * @return oluşturulan görev
     */
    public Task createTask(final Task task) {
        String sql = "INSERT INTO tasks (title, completed) VALUES (?, ?)";

        try (
                Connection connection = DriverManager.getConnection(dbUrl);
                PreparedStatement statement = connection.prepareStatement(
                        sql,
                        Statement.RETURN_GENERATED_KEYS
                )
        ) {

            statement.setString(FIRST_COLUMN, task.getTitle());
            statement.setInt(SECOND_COLUMN, task.isCompleted() ? 1 : 0);
            statement.executeUpdate();

            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    task.setId(keys.getInt(FIRST_COLUMN));
                }
            }
            return task;
        } catch (SQLException exception) {
            throw new RuntimeException("Failed to create task", exception);
        }
    }

    /**
     * @param id güncellenecek görev kimliği
     * @param task güncellenecek görev içeriği
     * @return güncelleme başarılıysa true
     */
    public boolean updateTask(final int id, final Task task) {
        String sql = "UPDATE tasks SET title = ?, completed = ? WHERE id = ?";

        try (Connection connection = DriverManager.getConnection(dbUrl);
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(FIRST_COLUMN, task.getTitle());
            statement.setInt(SECOND_COLUMN, task.isCompleted() ? 1 : 0);
            statement.setInt(THIRD_COLUMN, id);
            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            throw new RuntimeException("Failed to update task", exception);
        }
    }

    /**
     * @param id silinecek görev kimliği
     * @return silme başarılıysa true
     */
    public boolean deleteTask(final int id) {
        String sql = "DELETE FROM tasks WHERE id = ?";

        try (Connection connection = DriverManager.getConnection(dbUrl);
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(FIRST_COLUMN, id);
            return statement.executeUpdate() > 0;
        } catch (SQLException exception) {
            throw new RuntimeException("Failed to delete task", exception);
        }
    }
}
