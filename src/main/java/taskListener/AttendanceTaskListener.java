package taskListener;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class AttendanceTaskListener implements ServletContextListener {
    private AttendanceTask attendanceTask;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        attendanceTask = new AttendanceTask();
        attendanceTask.start(); // 启动定时任务
        System.out.println("考勤定时任务已启动。");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        attendanceTask.stop(); // 停止定时任务
        System.out.println("考勤定时任务已停止。");
    }
}
