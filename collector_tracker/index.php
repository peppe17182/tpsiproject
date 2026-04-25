<?php
// =============================================================
// index.php - Router principale (Front Controller)
//
// Questo e' l'unico script eseguito direttamente dal web server.
// Viene invocato per TUTTE le richieste grazie al RewriteRule
// definito nel file .htaccess.
//
// Logica:
//   1. Include i file di configurazione e supporto da /general
//   2. Verifica l'autorizzazione della richiesta
//   3. Analizza l'URL e il metodo HTTP
//   4. Instrada la richiesta verso il file corretto in /specific
// =============================================================

// --- Inclusione dei file di supporto generali ---
require_once __DIR__ . '/general/config.php';
require_once __DIR__ . '/general/response_helper.php';
require_once __DIR__ . '/general/db_helper.php';

// --- Autorizzazione (Elemento di innovazione) ---
checkAuthorization();

// --- Parsing dell'URL ---
// .htaccess trasforma "/items/category/5" in "index.php?url=items/category/5"
$url = isset($_GET['url']) ? trim($_GET['url'], '/') : '';
$parts = $url !== '' ? explode('/', $url) : [];

// Estrazione dei segmenti dell'URL
$resource = $parts[0] ?? '';   // Es. "items", "users", "categories", "stats"
$param1   = $parts[1] ?? null; // Es. un ID numerico oppure un sotto-percorso ("category", "rankings")
$param2   = $parts[2] ?? null; // Es. ID per URL composte ("/items/category/5")

// --- Metodo HTTP ---
$method = $_SERVER['REQUEST_METHOD'];

// --- Routing: smistamento verso il manager corretto ---
switch ($resource) {

    case 'users':
        require_once __DIR__ . '/specific/UserManager.php';
        handleUsers($method, $param1);
        break;

    case 'categories':
        require_once __DIR__ . '/specific/CategoryManager.php';
        handleCategories($method, $param1);
        break;

    case 'items':
        require_once __DIR__ . '/specific/ItemManager.php';
        // param1 puo' essere un ID numerico oppure un sotto-percorso
        // param2 e' l'ID del filtro per URL composte
        handleItems($method, $param1, $param2);
        break;

    case 'stats':
        require_once __DIR__ . '/specific/StatsManager.php';
        handleStats($method, $param1);
        break;

    default:
        sendResponse(404, ['error' => 'Risorsa non trovata.']);
        break;
}
