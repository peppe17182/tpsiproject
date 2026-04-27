<?php
// =============================================================
// index.php - Router principale per l'API Backend
// =============================================================

// Caricamento configurazioni e logiche core
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/core/Response.php';
require_once __DIR__ . '/core/Auth.php';

// Connessione PDO gestita centralmente
try {
    $pdo = getDbConnection();
} catch (Exception $e) {
    sendError(500, "Errore critico di sistema: DB offline.");
}

// Parsing URL
$url = isset($_GET['url']) ? trim($_GET['url'], '/') : '';
$parts = $url !== '' ? explode('/', $url) : [];

$resource = $parts[0] ?? '';   
$param1   = $parts[1] ?? null; 
$method   = $_SERVER['REQUEST_METHOD'];

// Instradamento ai controller API
switch ($resource) {
    case 'auth':
        require_once __DIR__ . '/api/Auth.php';
        // /auth/login, /auth/register, /auth/me
        handleAuth($pdo, $method, $param1);
        break;

    case 'items':
        require_once __DIR__ . '/api/Item.php';
        handleItems($pdo, $method, $param1);
        break;

    case 'users':
    case 'user':
        require_once __DIR__ . '/api/User.php';
        // Gestione profilo corrente
        handleUser($pdo, $method, $param1);
        break;

    case 'stats':
        require_once __DIR__ . '/api/Stats.php';
        // /stats, /stats/65
        handleStats($pdo, $method, $param1);
        break;

    case 'upload':
        require_once __DIR__ . '/api/Upload.php';
        handleUpload($pdo, $method, $param1);
        break;

    case 'categories':
        require_once __DIR__ . '/api/Category.php';
        handleCategories($pdo, $method, $param1);
        break;

    default:
        sendError(404, "Risorsa o endpoint non trovato.");
        break;
}
