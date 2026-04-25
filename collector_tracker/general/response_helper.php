<?php
// =============================================================
// general/response_helper.php - Funzioni di supporto per le
// risposte HTTP e la gestione dell'input JSON.
// =============================================================

/**
 * Invia una risposta JSON al client con il codice di stato HTTP
 * specificato e termina immediatamente l'esecuzione dello script.
 *
 * @param int   $statusCode Codice di stato HTTP (200, 201, 400, 404, 405, 500)
 * @param mixed $data       Dati da codificare in JSON
 */
function sendResponse($statusCode, $data) {
    header('Content-Type: application/json; charset=utf-8');
    http_response_code($statusCode);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * Legge e decodifica il corpo (body) della richiesta HTTP come JSON.
 * Utilizzata per i metodi POST, PUT e PATCH.
 *
 * @return array|null Array associativo dei dati ricevuti, o null se invalido
 */
function getJsonInput() {
    $raw = file_get_contents('php://input');
    return json_decode($raw, true);
}

/**
 * Elemento di innovazione: gestione autorizzazioni.
 * Verifica che la richiesta contenga una API Key valida,
 * tramite header HTTP "X-API-Key" oppure parametro query string "api_key".
 * Se la chiave non corrisponde, risponde con 401 Unauthorized.
 */
function checkAuthorization() {
    // Se nessuna API key e' configurata, salta il controllo
    if (API_KEY === '') {
        return;
    }

    $providedKey = null;

    // Priorita' 1: header HTTP
    $headers = getallheaders();
    if (isset($headers['X-API-Key'])) {
        $providedKey = $headers['X-API-Key'];
    } elseif (isset($headers['x-api-key'])) {
        // Alcuni server normalizzano gli header in minuscolo
        $providedKey = $headers['x-api-key'];
    }

    // Priorita' 2: parametro query string (comodo per test da browser)
    if ($providedKey === null && isset($_GET['api_key'])) {
        $providedKey = $_GET['api_key'];
    }

    if ($providedKey !== API_KEY) {
        sendResponse(401, ['error' => 'Non autorizzato. API Key mancante o non valida.']);
    }
}
