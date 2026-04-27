-- =============================================================
-- Collector Tracker - Script DDL per la creazione del database
-- =============================================================

CREATE DATABASE IF NOT EXISTS collector_tracker
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE collector_tracker;

-- Tabella Utenti (collezionisti)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    api_token VARCHAR(128) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabella Categorie (tipologie di oggetti da collezione)
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_categories_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT unique_user_category UNIQUE (name, user_id)
) ENGINE=InnoDB;

-- Tabella Oggetti (entita' principale del sistema)
-- Ogni oggetto appartiene a un utente e a una categoria
CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    rating INT NOT NULL DEFAULT 1 CHECK (rating BETWEEN 1 AND 10),
    acquisition_date DATE,
    image_url VARCHAR(255),
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_items_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_items_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB;
