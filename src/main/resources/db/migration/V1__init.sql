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
