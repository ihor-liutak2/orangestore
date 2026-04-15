# Модуль користувача: Firebase Authentication + Java Servlet + Hibernate + FreeMarker

## Загальна ідея

У проєкті `orangestore` аутентифікація побудована так:

- **Firebase Authentication** відповідає за:
    - реєстрацію користувача
    - вхід через email і пароль
    - вхід через Google
    - відновлення пароля

- **Java backend** відповідає за:
    - перевірку Firebase ID token
    - створення серверної HTTP-сесії
    - синхронізацію користувача з MySQL
    - відображення сторінок профілю та авторизації

- **Hibernate** відповідає за:
    - роботу з таблицею `users`
    - збереження та пошук користувача в MySQL

- **FreeMarker views** відповідають за:
    - сторінки login / register / forgot-password / profile
    - базовий layout
    - відображення поточного користувача в інтерфейсі

---

# Архітектура

## Потік роботи

```text
Користувач відкриває сторінку login/register
        ↓
FreeMarker рендерить HTML + JavaScript
        ↓
Firebase JS виконує register / login / Google login
        ↓
Firebase повертає ID token
        ↓
JavaScript надсилає idToken на /auth/session
        ↓
UserServlet отримує token
        ↓
Firebase Admin SDK перевіряє token
        ↓
FirebaseUserService знаходить або створює користувача в MySQL
        ↓
UserServlet створює HTTP session
        ↓
Користувач переходить на /user/profile
````

---

# 1. Firebase Authentication

## Що робить Firebase

Firebase Authentication виконує всю реальну аутентифікацію:

* створення користувача по email/password
* вхід по email/password
* вхід через Google
* надсилання листа для скидання пароля

Ми **не зберігаємо пароль у MySQL**.

Паролі зберігаються та перевіряються у Firebase.

---

## Приклад реєстрації на фронтенді

```javascript
const credential = await createUserWithEmailAndPassword(auth, email, password);
const user = credential.user;
const idToken = await user.getIdToken();
```

Після цього frontend надсилає токен на бекенд:

```javascript
await fetch(window.appConfig.contextPath + "/auth/session", {
    method: "POST",
    headers: {
        "Content-Type": "application/json"
    },
    body: JSON.stringify({ idToken })
});
```

---

## Приклад входу

```javascript
const credential = await signInWithEmailAndPassword(auth, email, password);
await sendTokenToBackend(credential.user);
```

---

## Приклад входу через Google

```javascript
const provider = new GoogleAuthProvider();
const credential = await signInWithPopup(auth, provider);
await sendTokenToBackend(credential.user);
```

---

## Приклад відновлення пароля

```javascript
await sendPasswordResetEmail(auth, email);
```

---

# 2. FirebaseConfig

## Призначення класу

Клас `FirebaseConfig` виконує дві ролі:

1. **Ініціалізація Firebase Admin SDK на бекенді**
2. **Надання конфігурації Firebase Web для views**

---

## Що читає `FirebaseConfig`

Клас читає файл:

```text
src/main/resources/project.properties
```

У ньому зберігаються:

* шлях до service account JSON
* Firebase Web config
* параметри БД
* параметри Hibernate

---

## Приклад Firebase properties

```properties
firebase.service.account.path=/home/ihorlt/edu/orangestore/firebase-service-account.json

firebase.web.apiKey=YOUR_API_KEY
firebase.web.authDomain=YOUR_PROJECT.firebaseapp.com
firebase.web.projectId=YOUR_PROJECT_ID
firebase.web.storageBucket=YOUR_PROJECT.firebasestorage.app
firebase.web.messagingSenderId=YOUR_SENDER_ID
firebase.web.appId=YOUR_APP_ID
firebase.web.measurementId=G-XXXXXXXXXX
```

---

## Ініціалізація Firebase Admin SDK

Метод:

```java
FirebaseConfig.init();
```

робить таке:

* відкриває service account JSON
* створює `GoogleCredentials`
* викликає `FirebaseApp.initializeApp(...)`

Це потрібно для серверної перевірки токенів.

---

## Отримання фронтенд-конфігурації

Метод:

```java
FirebaseConfig.getFirebaseWebConfig();
```

повертає `Map<String, Object>` з такими полями:

* `firebaseWebApiKey`
* `firebaseWebAuthDomain`
* `firebaseWebProjectId`
* `firebaseWebStorageBucket`
* `firebaseWebMessagingSenderId`
* `firebaseWebAppId`
* `firebaseWebMeasurementId`

Потім цей набір даних передається у views через фільтр.

---

# 3. ViewModelFilter

## Призначення фільтра

Фільтр `ViewModelFilter` виконується для всіх запитів:

```java
@WebFilter("/*")
```

Його задача — додати до `request` спільні дані, які потрібні будь-якому шаблону FreeMarker.

---

## Що саме додає фільтр

### Загальні дані

```java
request.setAttribute("contextPath", httpRequest.getContextPath());
```

### Firebase Web Config

Фільтр бере map із:

```java
FirebaseConfig.getFirebaseWebConfig()
```

і додає кожен елемент у `request`.

### Дані поточного користувача

Якщо є активна сесія, фільтр додає:

* `isAuthenticated`
* `currentUserId`
* `currentUserEmail`
* `currentUserRole`
* `currentDisplayName`
* `currentUserPhotoUrl`
* `currentFirebaseUid`
* `currentAuthProvider`
* `currentEmailVerified`
* `currentUserEnabled`

---

## Чому це зручно

Завдяки цьому будь-який шаблон FreeMarker може використовувати ці змінні без дублювання логіки в кожному сервлеті.

---

# 4. layout.ftl

## Призначення layout

Файл:

```text
src/main/resources/templates/layout.ftl
```

це базовий шаблон сторінки.

Він містить:

* HTML-обгортку
* navbar
* footer
* Bootstrap
* глобальний JavaScript config
* кнопку logout

---

## Як у layout формується frontend config

У layout створюється:

```javascript
window.appConfig = {
    contextPath: "...",
    firebaseConfig: {
        apiKey: "...",
        authDomain: "...",
        projectId: "...",
        storageBucket: "...",
        messagingSenderId: "...",
        appId: "...",
        measurementId: "..."
    },
    auth: {
        isAuthenticated: true,
        userId: "...",
        email: "...",
        displayName: "...",
        role: "...",
        firebaseUid: "...",
        provider: "...",
        emailVerified: true,
        enabled: true,
        photoUrl: "..."
    }
};
```

---

## Для чого потрібен `window.appConfig`

Щоб усі сторінки могли використовувати одні й ті самі налаштування:

```javascript
const app = initializeApp(window.appConfig.firebaseConfig);
const auth = getAuth(app);
```

і не дублювати конфігурацію вручну у кожному шаблоні.

---

# 5. User views

У проєкті є views:

```text
templates/user/login.ftl
templates/user/register.ftl
templates/user/forgot-password.ftl
templates/user/profile.ftl
```

---

## login.ftl

Сторінка входу містить:

* форму email/password
* кнопку Google login
* посилання на forgot-password
* посилання на register

При натисканні:

* Firebase виконує login
* отримується `idToken`
* токен надсилається на `/auth/session`

---

## register.ftl

Сторінка реєстрації містить:

* email
* password
* confirmPassword

Після успішної реєстрації:

* Firebase створює користувача
* frontend отримує токен
* токен надсилається на `/auth/session`
* бекенд синхронізує користувача з MySQL
* створюється HTTP session

---

## forgot-password.ftl

Сторінка виконує тільки одну задачу:

```javascript
sendPasswordResetEmail(auth, email);
```

Firebase сам надсилає лист користувачу.

---

## profile.ftl

Сторінка профілю використовує атрибути, які прийшли з фільтра:

* `currentUserId`
* `currentFirebaseUid`
* `currentUserEmail`
* `currentDisplayName`
* `currentAuthProvider`
* `currentUserRole`
* `currentEmailVerified`
* `currentUserEnabled`
* `currentUserPhotoUrl`

Ці дані відображаються у картках профілю.

---

# 6. UserServlet

## Призначення

`UserServlet` обслуговує і HTML-сторінки, і auth endpoint-и.

### Підтримувані маршрути

```text
GET  /user/login
GET  /user/register
GET  /user/forgot-password
GET  /user/profile

POST /auth/session
POST /auth/logout

GET  /auth/me
```

---

## GET маршрути

### `/user/login`

Рендерить `user/login.ftl`

### `/user/register`

Рендерить `user/register.ftl`

### `/user/forgot-password`

Рендерить `user/forgot-password.ftl`

### `/user/profile`

Рендерить `user/profile.ftl`, якщо користувач авторизований.
Інакше — redirect на login.

### `/auth/me`

Повертає JSON з даними користувача з session.

---

## POST `/auth/session`

Це найважливіший endpoint.

### Що він робить

1. читає JSON:

```json
{
  "idToken": "..."
}
```

2. викликає:

```java
firebaseUserService.authenticateAndSync(idToken)
```

3. отримує об’єкт `User`
4. створює HTTP session
5. зберігає в session:

* `userId`
* `firebaseUid`
* `userEmail`
* `displayName`
* `userRole`
* `provider`
* `emailVerified`
* `enabled`
* `photoUrl`

6. повертає JSON з результатом

---

## POST `/auth/logout`

Цей endpoint:

* invalidates HTTP session
* повертає JSON:

```json
{
  "status": "logged_out"
}
```

---

## GET `/auth/me`

Якщо є авторизація, повертає JSON-профіль користувача.

Якщо немає — повертає `401 Unauthorized`.

---

# 7. FirebaseUserService

## Призначення

`FirebaseUserService` — це міст між Firebase і MySQL.

---

## Що він робить

Метод:

```java
authenticateAndSync(String idToken)
```

виконує:

1. `FirebaseConfig.init()`
2. `FirebaseAuth.getInstance().verifyIdToken(idToken)`
3. отримує:

    * `uid`
    * `email`
    * `displayName`
    * `picture`
    * provider
4. шукає користувача в MySQL:

    * спочатку по `firebaseUid`
    * потім по `email`
5. якщо користувача немає — створює нового
6. оновлює дані
7. зберігає через `UserDao`

---

## Приклад логіки

```java
FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
String uid = decodedToken.getUid();
String email = decodedToken.getEmail();
```

Після цього створюється або оновлюється запис у MySQL.

---

# 8. HibernateUtil

## Призначення

`HibernateUtil` створює один глобальний `SessionFactory`.

---

## Як це працює

1. читається `project.properties`
2. зчитуються:

    * `db.driver`
    * `db.url`
    * `db.user`
    * `db.password`
    * `hibernate.dialect`
    * `hibernate.show_sql`
    * `hibernate.hbm2ddl.auto`
3. ці властивості явно передаються у Hibernate через `setProperty(...)`
4. будується `SessionFactory`

---

## Чому ми не використовуємо `${db.url}` у `hibernate.cfg.xml`

Тому що Hibernate не підставляє ці значення автоматично з `project.properties` у вигляді плейсхолдерів.

Тобто ось таке рішення є неправильним:

```xml
<property name="hibernate.connection.url">${db.url}</property>
```

Тому ми залишили `hibernate.cfg.xml` майже порожнім, а реальні значення задаємо в Java-коді.

---

## Поточний підхід

### `hibernate.cfg.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE hibernate-configuration PUBLIC
        "-//Hibernate/Hibernate Configuration DTD 3.0//EN"
        "http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd">

<hibernate-configuration>
    <session-factory>
    </session-factory>
</hibernate-configuration>
```

### Налаштування йдуть із `HibernateUtil`

```java
configuration.setProperty("hibernate.connection.driver_class", properties.getProperty("db.driver"));
configuration.setProperty("hibernate.connection.url", properties.getProperty("db.url"));
configuration.setProperty("hibernate.connection.username", properties.getProperty("db.user"));
configuration.setProperty("hibernate.connection.password", properties.getProperty("db.password"));
```

---

# 9. MySQL users table

Для інтеграції з Firebase таблиця `users` не зберігає паролі.

Вона зберігає лише зв’язок із Firebase-користувачем та бізнес-дані.

---

## Приклад таблиці

```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    firebase_uid VARCHAR(128) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255) NULL,
    first_name VARCHAR(100) NULL,
    last_name VARCHAR(100) NULL,
    photo_url VARCHAR(500) NULL,
    provider VARCHAR(50) NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'USER',
    enabled TINYINT(1) NOT NULL DEFAULT 1,
    email_verified TINYINT(1) NOT NULL DEFAULT 0,
    last_login_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
);
```

---

# 10. Логіка авторизації по кроках

## Реєстрація

1. користувач відкриває `/user/register`
2. вводить email і пароль
3. Firebase створює акаунт
4. frontend отримує `idToken`
5. frontend надсилає токен на `/auth/session`
6. backend перевіряє токен
7. backend створює запис у MySQL
8. backend створює HTTP session
9. frontend переходить на `/user/profile`

---

## Вхід

1. користувач відкриває `/user/login`
2. вводить email і пароль
3. Firebase виконує login
4. frontend отримує `idToken`
5. frontend надсилає токен на `/auth/session`
6. backend перевіряє токен
7. backend знаходить або оновлює користувача в MySQL
8. backend створює HTTP session
9. frontend переходить на `/user/profile`

---

## Вхід через Google

1. користувач натискає кнопку Google login
2. Firebase відкриває popup
3. користувач проходить автентифікацію через Google
4. frontend отримує `idToken`
5. frontend надсилає токен на `/auth/session`
6. backend перевіряє токен
7. backend знаходить або створює користувача в MySQL
8. backend створює HTTP session

---

## Відновлення пароля

1. користувач відкриває `/user/forgot-password`
2. вводить email
3. Firebase надсилає лист
4. backend у цьому потоці не бере участі

---

## Вихід

1. користувач натискає кнопку logout
2. у `layout.ftl` виконується:

    * `signOut(auth)` для Firebase
    * `POST /auth/logout` для бекенда
3. HTTP session знищується
4. користувач перенаправляється на `/user/login`

---

# 11. Чому це рішення хороше

## Переваги

### Паролі не зберігаються в MySQL

Це безпечніше і спрощує backend.

### Firebase бере на себе складну логіку auth

Не потрібно вручну писати:

* хешування паролів
* Google OAuth
* email reset flow

### MySQL зберігає лише бізнес-користувача

Тобто:

* ролі
* доступ
* профіль
* замовлення
* зв’язки з іншими таблицями

### Frontend і backend розділені логічно

* frontend аутентифікує
* backend перевіряє токен і працює з БД

---

# 12. Важливі зауваження

## Не можна передавати в layout service account JSON

У frontend можна віддавати тільки:

* apiKey
* authDomain
* projectId
* storageBucket
* messagingSenderId
* appId
* measurementId

Але не можна віддавати:

* private_key
* client_email
* service account JSON

---

## Якщо користувач створився у Firebase, але не з’явився в MySQL

Це означає, що проблема на бекенді:

* помилка у Firebase Admin SDK
* помилка в Hibernate
* помилка в `UserDao`
* помилка мапінгу entity

---

## Якщо `layout.ftl` не бачить змінні

Треба перевірити, чи під час рендеру сервлет змішує:

* `request attributes`
* локальну `model`

---

# 13. Підсумок

У поточній реалізації ми побудували повний auth-модуль:

* **Firebase** виконує аутентифікацію
* **FirebaseConfig** керує конфігурацією
* **ViewModelFilter** готує дані для шаблонів
* **layout.ftl** формує глобальний JavaScript config
* **User views** показують сторінки login/register/forgot-password/profile
* **UserServlet** обробляє маршрути та HTTP session
* **FirebaseUserService** синхронізує Firebase-користувача з MySQL
* **HibernateUtil** конфігурує Hibernate і підключення до БД
* **MySQL users** зберігає локального бізнес-користувача

Це дає чисту архітектуру, де:

* аутентифікація централізована у Firebase
* backend не працює з паролями
* користувачі зберігаються локально для ролей і бізнес-логіки
* сторінки використовують єдину конфігурацію через `layout.ftl`

```
```
