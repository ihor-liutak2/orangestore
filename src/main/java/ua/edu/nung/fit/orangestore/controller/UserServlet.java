package ua.edu.nung.fit.orangestore.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import ua.edu.nung.fit.orangestore.model.User;
import ua.edu.nung.fit.orangestore.service.FirebaseUserService;
import ua.edu.nung.fit.orangestore.util.FirebaseAuthRequest;

import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@WebServlet(urlPatterns = {
        "/user/login",
        "/user/register",
        "/user/forgot-password",
        "/user/profile",
        "/auth/session",
        "/auth/logout",
        "/auth/me"
})
public class UserServlet extends HttpServlet {

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final FirebaseUserService firebaseUserService = new FirebaseUserService();

    private Configuration freemarkerConfig;

    @Override
    public void init() throws ServletException {
        Object config = getServletContext().getAttribute("freemarkerConfig");

        if (config instanceof Configuration) {
            this.freemarkerConfig = (Configuration) config;
            return;
        }

        Configuration configuration = new Configuration(Configuration.VERSION_2_3_34);
        configuration.setClassLoaderForTemplateLoading(
                Thread.currentThread().getContextClassLoader(),
                "templates"
        );
        configuration.setDefaultEncoding("UTF-8");

        this.freemarkerConfig = configuration;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        String servletPath = req.getServletPath();

        switch (servletPath) {
            case "/user/login":
                renderLoginPage(req, resp);
                break;
            case "/user/register":
                renderRegisterPage(req, resp);
                break;
            case "/user/forgot-password":
                renderForgotPasswordPage(req, resp);
                break;
            case "/user/profile":
                renderProfilePage(req, resp);
                break;
            case "/auth/me":
                getCurrentUser(req, resp);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String servletPath = req.getServletPath();

        switch (servletPath) {
            case "/auth/session":
                createSession(req, resp);
                break;
            case "/auth/logout":
                logout(req, resp);
                break;
            default:
                sendJson(resp, HttpServletResponse.SC_NOT_FOUND, Map.of("error", "Endpoint not found"));
        }
    }

    private void renderLoginPage(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        Map<String, Object> model = new HashMap<>();
        model.put("title", "Вхід");
        renderTemplate(req, resp, "user/login.ftl", model);
    }

    private void renderRegisterPage(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        Map<String, Object> model = new HashMap<>();
        model.put("title", "Реєстрація");
        renderTemplate(req, resp, "user/register.ftl", model);
    }

    private void renderForgotPasswordPage(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        Map<String, Object> model = new HashMap<>();
        model.put("title", "Відновлення пароля");
        renderTemplate(req, resp, "user/forgot-password.ftl", model);
    }

    private void renderProfilePage(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/user/login");
            return;
        }

        Map<String, Object> model = new HashMap<>();
        model.put("title", "Профіль");

        renderTemplate(req, resp, "user/profile.ftl", model);
    }

    private void createSession(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            FirebaseAuthRequest authRequest = objectMapper.readValue(req.getInputStream(), FirebaseAuthRequest.class);

            if (authRequest.getIdToken() == null || authRequest.getIdToken().isBlank()) {
                sendJson(resp, HttpServletResponse.SC_BAD_REQUEST, Map.of("error", "idToken is required"));
                return;
            }

            System.out.println("Received Firebase token");

            User user = firebaseUserService.authenticateAndSync(authRequest.getIdToken());

            System.out.println("User authenticated and synced: " + user.getEmail());

            HttpSession session = req.getSession(true);
            session.setAttribute("userId", user.getId());
            session.setAttribute("firebaseUid", user.getFirebaseUid());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("displayName", user.getDisplayName());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("provider", user.getProvider());
            session.setAttribute("emailVerified", user.getEmailVerified());
            session.setAttribute("enabled", user.getEnabled());
            session.setAttribute("photoUrl", user.getPhotoUrl());

            Map<String, Object> result = new HashMap<>();
            result.put("status", "ok");
            result.put("userId", user.getId());
            result.put("email", user.getEmail());
            result.put("displayName", user.getDisplayName());
            result.put("role", user.getRole());
            result.put("provider", user.getProvider());

            sendJson(resp, HttpServletResponse.SC_OK, result);

        } catch (Exception e) {
            sendJson(resp, HttpServletResponse.SC_UNAUTHORIZED, Map.of(
                    "error", "Authentication failed",
                    "message", e.getMessage()
            ));
        }
    }

    private void logout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);

        if (session != null) {
            session.invalidate();
        }

        sendJson(resp, HttpServletResponse.SC_OK, Map.of("status", "logged_out"));
    }

    private void getCurrentUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            sendJson(resp, HttpServletResponse.SC_UNAUTHORIZED, Map.of("error", "Unauthorized"));
            return;
        }

        Map<String, Object> result = new HashMap<>();
        result.put("userId", session.getAttribute("userId"));
        result.put("firebaseUid", session.getAttribute("firebaseUid"));
        result.put("email", session.getAttribute("userEmail"));
        result.put("displayName", session.getAttribute("displayName"));
        result.put("role", session.getAttribute("userRole"));
        result.put("provider", session.getAttribute("provider"));
        result.put("emailVerified", session.getAttribute("emailVerified"));
        result.put("enabled", session.getAttribute("enabled"));
        result.put("photoUrl", session.getAttribute("photoUrl"));

        sendJson(resp, HttpServletResponse.SC_OK, result);
    }

    private void renderTemplate(HttpServletRequest req,
                                HttpServletResponse resp,
                                String templateName,
                                Map<String, Object> model)
            throws IOException, ServletException {

        resp.setContentType("text/html; charset=UTF-8");

        try {
            Map<String, Object> mergedModel = new HashMap<>();

            Enumeration<String> attributeNames = req.getAttributeNames();
            while (attributeNames.hasMoreElements()) {
                String name = attributeNames.nextElement();
                mergedModel.put(name, req.getAttribute(name));
            }

            mergedModel.putAll(model);

            Template template = freemarkerConfig.getTemplate(templateName);
            template.process(mergedModel, resp.getWriter());

        } catch (TemplateException e) {
            throw new ServletException("Failed to render template: " + templateName, e);
        }
    }

    private void sendJson(HttpServletResponse resp, int status, Object body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        objectMapper.writeValue(resp.getWriter(), body);
    }
}