package org.example.model;

/**
 * Görev modeli.
 */
public class Task {
    /** Görev kimliği. */
    private int id;
    /** Görev başlığı. */
    private String title;
    /** Tamamlanma durumu. */
    private boolean completed;

    /**
     * Varsayılan yapıcı.
     */
    public Task() {
    }

    /**
     * Parametreli yapıcı.
     *
     * @param taskId görev kimliği
     * @param taskTitle görev başlığı
     * @param taskCompleted tamamlanma durumu
     */
    public Task(
            final int taskId,
            final String taskTitle,
            final boolean taskCompleted
    ) {
        this.id = taskId;
        this.title = taskTitle;
        this.completed = taskCompleted;
    }

    /**
     * @return görev kimliği
     */
    public int getId() {
        return id;
    }

    /**
     * @param taskId görev kimliği
     */
    public void setId(final int taskId) {
        this.id = taskId;
    }

    /**
     * @return görev başlığı
     */
    public String getTitle() {
        return title;
    }

    /**
     * @param taskTitle görev başlığı
     */
    public void setTitle(final String taskTitle) {
        this.title = taskTitle;
    }

    /**
     * @return tamamlanma durumu
     */
    public boolean isCompleted() {
        return completed;
    }

    /**
     * @param taskCompleted tamamlanma durumu
     */
    public void setCompleted(final boolean taskCompleted) {
        this.completed = taskCompleted;
    }
}
