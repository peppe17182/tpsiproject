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
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabella Categorie (tipologie di oggetti da collezione)
CREATE TABLE IF NOT EXISTS categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Tabella Oggetti (entita' principale del sistema)
-- Ogni oggetto appartiene a un utente e a una categoria
CREATE TABLE IF NOT EXISTS items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    rating INT NOT NULL DEFAULT 1 CHECK (rating BETWEEN 1 AND 10),
    acquisition_date DATE,
    user_id INT NOT NULL,
    category_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- Dati di test
-- =============================================================

INSERT INTO users (username, email) VALUES
('mario_rossi', 'mario@example.com'),
('luigi_verdi', 'luigi@example.com'),
('anna_bianchi', 'anna@example.com');

INSERT INTO categories (name, description) VALUES
('Monete', 'Monete antiche e moderne da collezione'),
('Fumetti', 'Fumetti, manga e graphic novel'),
('Videogiochi', 'Videogiochi retro e moderni'),
('Orologi', 'Orologi da polso e da tasca vintage');

INSERT INTO items (name, description, rating, acquisition_date, user_id, category_id) VALUES
('Sesterzio Romano',       'Moneta in bronzo, epoca imperiale',       9, '2022-03-15', 1, 1),
('Denario Repubblicano',   'Moneta in argento, 100 a.C.',             8, '2023-01-20', 1, 1),
('Spider-Man #1',          'Prima edizione italiana, 1970',           10, '2021-06-10', 1, 2),
('NES Console',            'Nintendo Entertainment System completo',  9, '2020-11-05', 2, 3),
('Super Mario Bros 3',     'Cartuccia in box originale PAL',          8, '2021-12-25', 2, 3),
('Omega Seamaster 1960',   'Orologio automatico, condizioni ottime',  10, '2019-07-01', 2, 4),
('Dragon Ball vol. 1',     'Prima edizione giapponese Shonen Jump',   7, '2023-05-14', 3, 2),
('Game Boy Color',         'Edizione Pokemon, funzionante',           6, '2022-09-30', 3, 3),
('Sterlina Oro 1900',      'Moneta in oro, Re Edoardo VII',           10, '2024-01-10', 3, 1);
