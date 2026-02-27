package org.example.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import org.example.dao.TaskDAO;
import org.example.model.Task;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/api/tasks/*")
public class TasksServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /** Task veri erişim nesnesi. */
    private transient TaskDAO taskDAO;
    /** JSON serileştirme nesnesi. */
    private transient Gson gson;

    /**
     * Servlet bağımlılıklarını başlatır.
     *
     * @throws ServletException başlatma hatası olduğunda
     */
    @Override
    public void init() throws ServletException {
        super.init();
        this.taskDAO = new TaskDAO();
        this.gson = new Gson();
    }

    /**
     * Görevleri listeler veya tek görev döner.
     *
     * @param request HTTP isteği
     * @param response HTTP yanıtı
     * @throws IOException girdi/çıktı hatası
     */
    @Override
    protected void doGet(
            final HttpServletRequest request,
            final HttpServletResponse response
    ) throws IOException {
        prepareJsonResponse(response);

        Integer id = extractId(request);
        if (id == null
                && request.getPathInfo() != null
                && !"/".equals(request.getPathInfo())) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid task id"
            );
            return;
        }

        if (id == null) {
            List<Task> tasks = taskDAO.getAllTasks();
            response.getWriter().write(gson.toJson(tasks));
            return;
        }

        Task task = taskDAO.getTaskById(id);
        if (task == null) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Task not found"
            );
            return;
        }

        response.getWriter().write(gson.toJson(task));
    }

    /**
     * Yeni görev oluşturur.
     *
     * @param request HTTP isteği
     * @param response HTTP yanıtı
     * @throws IOException girdi/çıktı hatası
     */
    @Override
    protected void doPost(
            final HttpServletRequest request,
            final HttpServletResponse response
    ) throws IOException {
        prepareJsonResponse(response);

        Task incomingTask = readTaskFromRequest(request);
        if (isInvalidTask(incomingTask)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Task title is required"
            );
            return;
        }

        Task createdTask = taskDAO.createTask(
            new Task(
                0,
                incomingTask.getTitle().trim(),
                incomingTask.isCompleted()
            )
        );
        response.setStatus(HttpServletResponse.SC_CREATED);
        response.getWriter().write(gson.toJson(createdTask));
    }

    /**
     * Görev günceller.
     *
     * @param request HTTP isteği
     * @param response HTTP yanıtı
     * @throws IOException girdi/çıktı hatası
     */
    @Override
    protected void doPut(
            final HttpServletRequest request,
            final HttpServletResponse response
    ) throws IOException {
        prepareJsonResponse(response);

        Integer id = extractId(request);
        if (id == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Task id is required in path"
            );
            return;
        }

        Task incomingTask = readTaskFromRequest(request);
        if (isInvalidTask(incomingTask)) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Task title is required"
            );
            return;
        }

        boolean updated = taskDAO.updateTask(
                id,
            new Task(
                id,
                incomingTask.getTitle().trim(),
                incomingTask.isCompleted()
            )
        );
        if (!updated) {
            response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Task not found"
            );
            return;
        }

        Task task = taskDAO.getTaskById(id);
        response.getWriter().write(gson.toJson(task));
    }

    /**
     * Görev siler.
     *
     * @param request HTTP isteği
     * @param response HTTP yanıtı
     * @throws IOException girdi/çıktı hatası
     */
    @Override
    protected void doDelete(
            final HttpServletRequest request,
            final HttpServletResponse response
    ) throws IOException {
        Integer id = extractId(request);
        if (id == null) {
            response.sendError(
                    HttpServletResponse.SC_BAD_REQUEST,
                    "Task id is required in path"
            );
            return;
        }

        boolean deleted = taskDAO.deleteTask(id);
        if (!deleted) {
            response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "Task not found"
            );
            return;
        }

        response.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }

    private void prepareJsonResponse(final HttpServletResponse response) {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
    }

    private boolean isInvalidTask(final Task task) {
        return task == null
                || task.getTitle() == null
                || task.getTitle().trim().isEmpty();
    }

    private Task readTaskFromRequest(final HttpServletRequest request)
            throws IOException {
        try {
            return gson.fromJson(request.getReader(), Task.class);
        } catch (JsonSyntaxException exception) {
            return null;
        }
    }

    private Integer extractId(final HttpServletRequest request) {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.isEmpty() || "/".equals(pathInfo)) {
            return null;
        }

        String normalizedPath = pathInfo.startsWith("/")
            ? pathInfo.substring(1)
            : pathInfo;
        if (normalizedPath.contains("/")) {
            return null;
        }

        try {
            return Integer.parseInt(normalizedPath);
        } catch (NumberFormatException exception) {
            return null;
        }
    }
}
