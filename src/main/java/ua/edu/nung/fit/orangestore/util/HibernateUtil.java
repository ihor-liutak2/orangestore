package ua.edu.nung.fit.orangestore.util;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

import java.io.InputStream;
import java.util.Properties;

public class HibernateUtil {

    private static final SessionFactory sessionFactory;

    static {
        try {
            Properties properties = new Properties();
            InputStream input = HibernateUtil.class
                    .getClassLoader()
                    .getResourceAsStream("project.properties");

            properties.load(input);

            Configuration configuration = new Configuration();
            configuration.configure("hibernate.cfg.xml");
            configuration.addProperties(properties);

            sessionFactory = configuration.buildSessionFactory();

        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    public static SessionFactory getSessionFactory() {
        return sessionFactory;
    }
}
