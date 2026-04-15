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
│ ├── ua.edu.nung.fit.orangestore.model/ # Сутності (Entity класи)
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
Перевірка чи працює MySQL сервер

```bash
sudo service mysql status
```

```bash
sudo service mysql start
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


## 🏗 Збірка та деплой застосунку

### 📦 1. Збірка WAR-файлу

Для створення WAR-архіву виконайте команду:

```bash
mvn clean package
```

Після успішної збірки файл буде створено за шляхом:

```
target/orangestore.war
```

---

### 🚀 2. Деплой через Maven (Cargo)

Проєкт налаштований на автоматичний деплой у **Apache Tomcat** за допомогою Maven Cargo Plugin.

#### 🔗 Параметри підключення до Tomcat Manager:

- **URL:** `http://localhost:8080/manager/text`
- **Логін / пароль:** `admin / admin`  
  (налаштовуються у файлі `conf/tomcat-users.xml`)

---

### ⚙ Налаштування користувача Tomcat Manager

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

Після цього перезапусти Tomcat.

---

### ▶ Виконати деплой

```bash
mvn cargo:deploy
```

---

### 🔄 Запуск із автоматичним стартом Tomcat

Для одночасної збірки, запуску Tomcat та деплою застосунку:

```bash
mvn clean package cargo:run
```

Після запуску застосунок буде доступний за адресою:

```
http://localhost:8080/orangestore
```

---

### 🛑 Зупинка сервера

Для зупинки Tomcat достатньо натиснути:

```
Ctrl + C
```


# Database Migrations (Flyway) – orangestore

## Overview

This project uses **Flyway** for database schema migrations and **Hibernate** only for validation (not schema generation).

Architecture:

- Flyway → manages database schema
- Hibernate → validates schema (`hbm2ddl.auto=validate`)
- Tomcat → runs application only
- Migrations are executed manually via Maven

---

## Project Structure

```
src/main/resources/
    project.properties
    db/
        migration/
            V1__init_schema.sql
            V2__add_units.sql
            V3__add_prices.sql
```

---

## project.properties

```properties
# ==========================
# Database (Hibernate)
# ==========================
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://localhost:3306/orangestore?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
db.user=ihorlt
db.password=1122

# ==========================
# Flyway
# ==========================
flyway.url=jdbc:mysql://localhost:3306/orangestore?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true
flyway.user=ihorlt
flyway.password=1122

# ==========================
# Hibernate
# ==========================
hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
hibernate.show_sql=true
hibernate.hbm2ddl.auto=validate

# ==========================
# Security
# ==========================
app.secret=verySecretKey123
jwt.secret=myJwtSecret
```

Explanation:
- `db.*` → used by Hibernate
- `flyway.*` → used by Flyway Maven plugin

---

## Maven Configuration (pom.xml)

Add Flyway plugin inside `<build><plugins>`:

```xml
<plugin>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-maven-plugin</artifactId>
    <version>10.17.0</version>

    <configuration>
        <configFiles>
            <configFile>src/main/resources/project.properties</configFile>
        </configFiles>

        <locations>
            <location>filesystem:src/main/resources/db/migration</location>
        </locations>
    </configuration>
</plugin>
```

Also ensure dependency exists:

```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
    <version>10.17.0</version>
</dependency>
```

---

## Migration Naming Convention

Flyway uses versioned SQL files:

```
V1__init_schema.sql
V2__create_units.sql
V3__create_fruit_prices.sql
V4__create_orders.sql
```

Rules:
- Must start with `V`
- Followed by version number
- Double underscore `__`
- Description
- `.sql` extension

---

## Running Migrations

Run migrations locally:

```
mvn flyway:migrate
```

Other useful commands:

```
mvn flyway:info
mvn flyway:validate
mvn flyway:repair
mvn flyway:clean   (⚠ deletes schema)
```

---

## How It Works

1. Flyway scans `db/migration`
2. Executes new SQL files in version order
3. Stores applied migrations in table:

```
flyway_schema_history
```

4. Hibernate validates schema at runtime

---

## Development Workflow

1. Create new SQL file:
   ```
   V5__add_stock_movements.sql
   ```

2. Run:
   ```
   mvn flyway:migrate
   ```

3. Start Tomcat:
   ```
   mvn clean package
   ```

4. Deploy WAR

---

## Important Notes

- Do NOT use `hibernate.hbm2ddl.auto=create` or `update`
- Always keep it:
  ```
  hibernate.hbm2ddl.auto=validate
  ```
- Never modify already executed migration files
- Create a new migration instead

---

## Final Architecture

```
users
fruits
units
fruit_prices
fruit_images
orders
order_items
```

Flyway manages schema evolution.
Hibernate manages ORM.
Tomcat runs the application.
