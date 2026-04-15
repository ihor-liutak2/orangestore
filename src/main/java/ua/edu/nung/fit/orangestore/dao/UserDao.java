package ua.edu.nung.fit.orangestore.dao;

import org.hibernate.Session;
import org.hibernate.Transaction;
import ua.edu.nung.fit.orangestore.model.User;
import ua.edu.nung.fit.orangestore.util.HibernateUtil;

public class UserDao {

    public User findByFirebaseUid(String firebaseUid) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                            "from User u where u.firebaseUid = :firebaseUid", User.class)
                    .setParameter("firebaseUid", firebaseUid)
                    .uniqueResult();
        }
    }

    public User findByEmail(String email) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return session.createQuery(
                            "from User u where u.email = :email", User.class)
                    .setParameter("email", email)
                    .uniqueResult();
        }
    }

    public User saveOrUpdate(User user) {
        Transaction transaction = null;

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            transaction = session.beginTransaction();
            session.merge(user);
            transaction.commit();
            return user;
        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            throw e;
        }
    }
}