# 🍊 OrangeStore – Навчальний веб-магазин

![OrangeStore](img/OIP.jpg)

## 📌 Опис проекту

**OrangeStore** – це навчальний веб-застосунок, який реалізує базовий функціонал інтернет-магазину.  
Проєкт створений з метою вивчення:

- Java (Servlet API)
- Hibernate (ORM)
- MySQL
- Maven
- Конфігурації через properties
- Структурування Java Web-проєктів

Застосунок демонструє класичну багаторівневу архітектуру з розділенням відповідальності між шарами.

---

## 🏗 Структура проекту

Проєкт побудований відповідно до стандартної структури Maven:

```
orangestore
│
├── pom.xml
├── img/ # Зображення для README та інтерфейсу
│
└── src
└── main
├── java
│ └── ua.nung.orangestore
│ ├── model/ # Сутності (Entity класи)
│ ├── dao/ # Доступ до бази даних
│ ├── service/ # Бізнес-логіка
│ └── util/ # Допоміжні класи (HibernateUtil)
│
├── resources
│ ├── hibernate.cfg.xml
│ ├── project.properties
│ └── project.properties.example
│
└── webapp
└── WEB-INF
└── web.xml

```


---

## ⚙ Технології

- Java 17
- Servlet API
- Hibernate ORM
- MySQL 8
- Maven
- JSP (за потреби)

---

## 🔐 Файл `project.properties`

Файл `project.properties` містить усі конфігураційні параметри застосунку, включаючи:

- параметри підключення до бази даних
- налаштування Hibernate
- секретні ключі
- інші змінні середовища

### Приклад:

```properties
# Database configuration
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/orangestore?serverTimezone=UTC
db.user=root
db.password=1122

# Hibernate
hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
hibernate.show_sql=true
hibernate.hbm2ddl.auto=update
```

Файл project.properties не повинен додаватися до Git-репозиторію.
Для цього використовується:

project.properties.example

де міститься приклад конфігурації без реальних паролів.

База даних

Перед запуском необхідно створити базу даних:

```sql
CREATE DATABASE orangestore;
```

## Запуск проекту

Налаштувати MySQL

Вказати правильні параметри у project.properties

Запустити через Tomcat або інший servlet-контейнер

Відкрити у браузері


## 🐱 Apache Tomcat: запуск і деплой

Проєкт збирається у форматі **WAR** і може деплоїтися у Apache Tomcat.

### Важливо про версію Tomcat
- **Tomcat 9** використовує `javax.servlet.*` (класичні сервлети).
- **Tomcat 10+** використовує `jakarta.servlet.*` (Jakarta EE 9+).

Якщо у коді використовується `javax.servlet.*`, рекомендовано запускати на **Tomcat 9**.  
Якщо проєкт мігровано на `jakarta.servlet.*`, тоді можна використовувати **Tomcat 10+**.

---

### 1) Увімкнення Tomcat Manager (для деплою через Maven Cargo)

Щоб Maven міг деплоїти WAR у Tomcat, потрібно налаштувати користувача Manager.

Відкрий файл:

```
$CATALINA_HOME/conf/tomcat-users.xml
```
Додай:

```xml
<role rolename="manager-script"/>
```

```xml
<role rolename="manager-gui"/>
```

```xml
<user username="admin" password="admin" roles="manager-script,manager-gui"/>
```
Перезапусти Tomcat.

Доступ до Manager

Перевір:

Manager UI: http://localhost:8080/manager/html

Manager text API: http://localhost:8080/manager/text


Збірка WAR
```bash
mvn clean package
```

Після цього WAR буде тут:

target/orangestore.war

Деплой через Maven (Cargo)

Maven налаштований на деплой через Tomcat Manager:

URL: http://localhost:8080/manager/text

username/password: admin/admin (з tomcat-users.xml)

Команда деплою:
```bash
mvn cargo:deploy
```

(За потреби також можна додати cargo:redeploy для повторного деплою.)