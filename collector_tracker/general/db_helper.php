<?php
// =============================================================
// general/db_helper.php - Funzioni di supporto per il database
//
// Contiene la funzione per ottenere una connessione PDO al
// database MySQL, utilizzando le costanti definite in config.php.
// =============================================================

/**
 * Restituisce un'istanza PDO connessa al database.
 * Usa prepared statements di default per prevenire SQL Injection.
 * In caso di errore, invia una risposta 500 e termina.
 *
 * @return PDO Connessione al database
 */
function getDbConnection() {
    static $pdo = null;

    // Connessione singleton: evita di riaprire la connessione
    // ad ogni chiamata durante la stessa richiesta HTTP
    if ($pdo !== null) {
        return $pdo;
    }

    try {
        $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';
        $pdo = new PDO($dsn, DB_USER, DB_PASS);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
        return $pdo;
    } catch (PDOException $e) {
        sendResponse(500, ['error' => 'Connessione al database fallita.']);
    }
}
