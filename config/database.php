<?php
// =============================================================
// config/database.php - Configurazione DB e Connessione PDO
// =============================================================

// Caricamento parametri da config.ini (NELLA DIRECTORY BASE COME DA SPECIFICHE BONUS)
$iniPath = __DIR__ . '/../config.ini';

if (!file_exists($iniPath)) {
    // Fallback: valori di default
    define('DB_HOST', '127.0.0.1');
    define('DB_NAME', 'collector_tracker');
    define('DB_USER', 'root');
    define('DB_PASS', '');
} else {
    $cfg = parse_ini_file($iniPath, true);
    define('DB_HOST', $cfg['database']['host'] ?? '127.0.0.1');
    define('DB_NAME', $cfg['database']['dbname'] ?? 'collector_tracker');
    define('DB_USER', $cfg['database']['user'] ?? 'root');
    define('DB_PASS', $cfg['database']['password'] ?? '');
}

/**
 * Restituisce un'istanza PDO connessa al database.
 * In caso di errore, lancia un'eccezione (catturata poi dal gestore globale).
 *
 * @return PDO
 */
function getDbConnection() {
    static $pdo = null;

    if ($pdo !== null) {
        return $pdo;
    }

    $dsn = 'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4';
    $pdo = new PDO($dsn, DB_USER, DB_PASS);
    
    // Configurazione per una gestione rigorosa degli errori e FETCH associativo
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    
    return $pdo;
}
