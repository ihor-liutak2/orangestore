CREATE TABLE users
(
    id           BIGINT PRIMARY KEY AUTO_INCREMENT,

    -- Firebase UID (основний ідентифікатор)
    firebase_uid VARCHAR(128) NOT NULL UNIQUE,

    -- Email з Firebase
    email        VARCHAR(255) NOT NULL UNIQUE,

    -- Роль у системі
    role         VARCHAR(50)  NOT NULL DEFAULT 'USER',

    -- Статус
    enabled      BOOLEAN      NOT NULL DEFAULT TRUE,

    -- Аудит
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    -- Додаткові поля (опційно)
    first_name   VARCHAR(100),
    last_name    VARCHAR(100),

    INDEX        idx_users_role (role)
);


CREATE TABLE fruits
(
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,

    name        VARCHAR(150) NOT NULL,
    description TEXT,
    unit        ENUM('kg', 'piece', 'box', 'g') NOT NULL DEFAULT 'kg',

    active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,

    INDEX       idx_fruits_active (active),
    INDEX       idx_fruits_name (name)
);


CREATE TABLE fruit_images
(
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,

    fruit_id   BIGINT       NOT NULL,

    file_name  VARCHAR(255) NOT NULL,
    file_path  VARCHAR(500) NULL,

    is_main    BOOLEAN      NOT NULL DEFAULT FALSE,
    sort_order INT          NOT NULL DEFAULT 0,

    alt_text   VARCHAR(255) NULL,

    created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fruit_images_fruit
        FOREIGN KEY (fruit_id)
            REFERENCES fruits (id)
            ON DELETE CASCADE,

    INDEX      idx_fruit_images_fruit (fruit_id),
    INDEX      idx_fruit_images_main (fruit_id, is_main)
);


CREATE TABLE fruit_prices
(
    id         BIGINT PRIMARY KEY AUTO_INCREMENT,

    fruit_id   BIGINT         NOT NULL,

    price      DECIMAL(10, 2) NOT NULL,
    currency   VARCHAR(10)    NOT NULL DEFAULT 'UAH',

    -- price validity window
    valid_from TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to   TIMESTAMP NULL,

    created_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fruit_prices_fruit
        FOREIGN KEY (fruit_id)
            REFERENCES fruits (id)
            ON DELETE CASCADE,

    INDEX      idx_fruit_prices_fruit (fruit_id),
    INDEX      idx_fruit_prices_validity (fruit_id, valid_from, valid_to)
);
