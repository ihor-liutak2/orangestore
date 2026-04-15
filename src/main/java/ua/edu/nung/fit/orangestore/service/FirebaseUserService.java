package ua.edu.nung.fit.orangestore.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import ua.edu.nung.fit.orangestore.dao.UserDao;
import ua.edu.nung.fit.orangestore.model.User;
import ua.edu.nung.fit.orangestore.util.FirebaseConfig;

import java.sql.Timestamp;
import java.util.Map;

public class FirebaseUserService {

    private final UserDao userDao = new UserDao();

    public User authenticateAndSync(String idToken) {
        try {
            FirebaseConfig.init();

            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();
            String email = decodedToken.getEmail();

            if (email == null || email.isBlank()) {
                throw new IllegalArgumentException("Email is missing in Firebase token");
            }

            User user = userDao.findByFirebaseUid(uid);
            if (user == null) {
                user = userDao.findByEmail(email);
            }
            if (user == null) {
                user = new User();
                user.setFirebaseUid(uid);
                user.setRole("USER");
                user.setEnabled(true);
            }

            user.setEmail(email);
            user.setDisplayName((String) decodedToken.getClaims().get("name"));
            user.setPhotoUrl((String) decodedToken.getClaims().get("picture"));
            user.setEmailVerified(Boolean.TRUE.equals(decodedToken.isEmailVerified()));
            user.setLastLoginAt(new Timestamp(System.currentTimeMillis()));
            user.setProvider(resolveProvider(decodedToken.getClaims()));

            splitDisplayName(user);
            userDao.saveOrUpdate(user);

            return user;
        } catch (Exception e) {
            throw new RuntimeException("Failed to authenticate Firebase user", e);
        }
    }

    private String resolveProvider(Map<String, Object> claims) {
        Object firebaseClaim = claims.get("firebase");
        if (firebaseClaim instanceof Map<?, ?> firebaseMap) {
            Object signInProvider = firebaseMap.get("sign_in_provider");
            if (signInProvider != null) {
                return signInProvider.toString();
            }
        }
        return "unknown";
    }

    private void splitDisplayName(User user) {
        String displayName = user.getDisplayName();
        if (displayName == null || displayName.isBlank()) {
            return;
        }

        String[] parts = displayName.trim().split("\\s+", 2);
        user.setFirstName(parts[0]);
        user.setLastName(parts.length > 1 ? parts[1] : null);
    }
}