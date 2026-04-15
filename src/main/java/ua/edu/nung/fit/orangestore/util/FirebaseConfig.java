package ua.edu.nung.fit.orangestore.util;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public final class FirebaseConfig {

    private static final Properties PROPERTIES = loadProperties();
    private static volatile boolean initialized = false;

    private FirebaseConfig() {
    }

    public static void init() {
        if (initialized || !FirebaseApp.getApps().isEmpty()) {
            initialized = true;
            return;
        }

        synchronized (FirebaseConfig.class) {
            if (initialized || !FirebaseApp.getApps().isEmpty()) {
                initialized = true;
                return;
            }

            try (InputStream serviceAccount = new FileInputStream(
                    getRequiredProperty("firebase.service.account.path"))) {

                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                        .build();

                FirebaseApp.initializeApp(options);
                initialized = true;

            } catch (Exception e) {
                throw new RuntimeException("Failed to initialize Firebase Admin SDK", e);
            }
        }
    }

    public static String getProperty(String key) {
        return PROPERTIES.getProperty(key);
    }

    public static String getRequiredProperty(String key) {
        String value = PROPERTIES.getProperty(key);
        if (value == null || value.isBlank()) {
            throw new IllegalStateException("Missing required property: " + key);
        }
        return value;
    }

    public static Map<String, Object> getFirebaseWebConfig() {
        Map<String, Object> config = new HashMap<>();
        config.put("firebaseWebApiKey", getRequiredProperty("firebase.web.apiKey"));
        config.put("firebaseWebAuthDomain", getRequiredProperty("firebase.web.authDomain"));
        config.put("firebaseWebProjectId", getRequiredProperty("firebase.web.projectId"));
        config.put("firebaseWebStorageBucket", getRequiredProperty("firebase.web.storageBucket"));
        config.put("firebaseWebMessagingSenderId", getRequiredProperty("firebase.web.messagingSenderId"));
        config.put("firebaseWebAppId", getRequiredProperty("firebase.web.appId"));
        config.put("firebaseWebMeasurementId", getRequiredProperty("firebase.web.measurementId"));
        return config;
    }

    private static Properties loadProperties() {
        try (InputStream input = FirebaseConfig.class.getClassLoader()
                .getResourceAsStream("project.properties")) {

            if (input == null) {
                throw new IllegalStateException("project.properties not found");
            }

            Properties properties = new Properties();
            properties.load(input);
            return properties;

        } catch (Exception e) {
            throw new RuntimeException("Failed to load project.properties", e);
        }
    }
}