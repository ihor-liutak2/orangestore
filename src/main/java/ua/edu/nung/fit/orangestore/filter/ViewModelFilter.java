package ua.edu.nung.fit.orangestore.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import ua.edu.nung.fit.orangestore.util.FirebaseConfig;

import java.io.IOException;
import java.util.Map;

@WebFilter("/*")
public class ViewModelFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;

        // contextPath
        request.setAttribute("contextPath", httpRequest.getContextPath());

        // 🔥 Firebase Web Config (через один централізований метод)
        Map<String, Object> firebaseAttrs = FirebaseConfig.getFirebaseWebConfig();
        for (Map.Entry<String, Object> entry : firebaseAttrs.entrySet()) {
            request.setAttribute(entry.getKey(), entry.getValue());
        }

        // 🔐 Session / Auth data
        HttpSession session = httpRequest.getSession(false);

        if (session != null && session.getAttribute("userId") != null) {
            request.setAttribute("isAuthenticated", true);

            request.setAttribute("currentUserId", session.getAttribute("userId"));
            request.setAttribute("currentUserEmail", session.getAttribute("userEmail"));
            request.setAttribute("currentUserRole", session.getAttribute("userRole"));
            request.setAttribute("currentDisplayName", session.getAttribute("displayName"));

            request.setAttribute("currentUserPhotoUrl", session.getAttribute("photoUrl"));
            request.setAttribute("currentFirebaseUid", session.getAttribute("firebaseUid"));
            request.setAttribute("currentAuthProvider", session.getAttribute("provider"));

            request.setAttribute("currentEmailVerified", session.getAttribute("emailVerified"));
            request.setAttribute("currentUserEnabled", session.getAttribute("enabled"));

        } else {
            request.setAttribute("isAuthenticated", false);
        }

        chain.doFilter(request, response);
    }
}