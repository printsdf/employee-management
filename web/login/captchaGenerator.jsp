<%@ page import="java.awt.*" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="javax.imageio.ImageIO" %>
<%@ page contentType="image/jpeg; charset=UTF-8" %>
<%
    int width = 120, height = 40;
    String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    StringBuilder captcha = new StringBuilder();

    for (int i = 0; i < 5; i++) {
        captcha.append(chars.charAt((int) (Math.random() * chars.length())));
    }

    session.setAttribute("captcha", captcha.toString());

    BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
    Graphics g = image.getGraphics();
    g.setColor(Color.LIGHT_GRAY);
    g.fillRect(0, 0, width, height);

    g.setFont(new Font("Arial", Font.BOLD, 24));
    g.setColor(Color.BLACK);
    g.drawString(captcha.toString(), 20, 28);

    g.dispose();
    ImageIO.write(image, "JPEG", response.getOutputStream());
%>
