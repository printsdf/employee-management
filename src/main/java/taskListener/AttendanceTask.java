package taskListener;

import java.sql.*;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class AttendanceTask {
    private ScheduledExecutorService scheduler;

    public void start() {
        scheduler = Executors.newScheduledThreadPool(1);

        // 获取当前时间到当天晚上 23:59 的时间间隔（毫秒）
        long delayUntilMidnight = getDelayUntilMidnight();

        // 定时任务，每天执行一次
        scheduler.scheduleAtFixedRate(() -> {
            System.out.println("开始执行每日考勤任务...");
            markAbsent(); // 调用任务逻辑
        }, delayUntilMidnight, 24 * 60 * 60 * 1000, TimeUnit.MILLISECONDS);
    }

    public void stop() {
        if (scheduler != null) {
            scheduler.shutdown();
            System.out.println("定时任务已停止。");
        }
    }

    private void markAbsent() {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            // 数据库连接
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/employeemanagement", "root", "123456");

            // 更新当天未签到或未签退的记录为缺勤
            String query = "UPDATE attendance " +
                           "SET status = 'absent' " +
                           "WHERE date = CURDATE() AND (check_in_time IS NULL OR check_out_time IS NULL)";
            stmt = conn.prepareStatement(query);
            int rowsUpdated = stmt.executeUpdate();
            System.out.println("已将 " + rowsUpdated + " 条未完成考勤记录标记为缺勤（absent）。");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private long getDelayUntilMidnight() {
        long currentTime = System.currentTimeMillis();
        long midnight = currentTime - (currentTime % (24 * 60 * 60 * 1000)) + (24 * 60 * 60 * 1000) - 60 * 1000; // 23:59
        return midnight - currentTime;
    }
}
