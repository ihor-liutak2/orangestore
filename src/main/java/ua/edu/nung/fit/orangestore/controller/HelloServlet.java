package ua.edu.nung.fit.orangestore.controller;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.Writer;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/hello")
public class HelloServlet extends HttpServlet {

    private Configuration cfg;

    @Override
    public void init() throws ServletException {
        cfg = new Configuration(Configuration.VERSION_2_3_34);
        cfg.setClassLoaderForTemplateLoading(
                Thread.currentThread().getContextClassLoader(),
                "templates"
        );
        cfg.setDefaultEncoding("UTF-8");
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        response.setCharacterEncoding("UTF-8");

        Map<String, Object> model = new HashMap<>();
        model.put("title", "OrangeStore - Hello");
        model.put("contextPath", request.getContextPath());
        model.put("message", "Hello from OrangeStore 🍊");
        model.put("description", "Tomcat + FreeMarker + Bootstrap are working correctly!");

        try {
            Template template = cfg.getTemplate("hello.ftl");
            Writer out = response.getWriter();
            template.process(model, out);
        } catch (TemplateException e) {
            throw new ServletException(e);
        }
    }
}

