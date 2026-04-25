<?php
// =============================================================
// general/config.php - Dati di configurazione
//
// Elemento di innovazione: i parametri vengono letti dal file
// config.ini (formato INI) posizionato nella directory base.
// Questo file li espone come costanti PHP utilizzabili dal
// resto dell'applicazione.
// =============================================================

$iniPath = __DIR__ . '/../config.ini';

if (!file_exists($iniPath)) {
    // Fallback: se il file INI non esiste, usiamo valori di default
    define('DB_HOST', '127.0.0.1');
    define('DB_NAME', 'collector_tracker');
    define('DB_USER', 'root');
    define('DB_PASS', '');
    define('API_KEY', '');
} else {
    $cfg = parse_ini_file($iniPath, true);

    define('DB_HOST', $cfg['database']['host']);
    define('DB_NAME', $cfg['database']['dbname']);
    define('DB_USER', $cfg['database']['user']);
    define('DB_PASS', $cfg['database']['password']);
    define('API_KEY', $cfg['security']['api_key']);
}
