<?php
// =============================================================
// core/Response.php - Gestione Standardizzata Output e Errori
// =============================================================

/**
 * Invia una risposta JSON standardizzata al client e termina lo script.
 * 
 * @param int   $statusCode Codice di stato HTTP
 * @param mixed $data       Dati da restituire (array o oggetto)
 */
function sendResponse($statusCode, $data) {
    header('Content-Type: application/json; charset=utf-8');
    http_response_code($statusCode);
    
    // Per garantire un formato standard anche per gli array vuoti
    if (empty($data) && is_array($data)) {
        echo json_encode((object)[]);
    } else {
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
    }
    exit;
}

/**
 * Invia un errore in un formato JSON standardizzato (RFC 7807 simile).
 *
 * @param int    $statusCode Codice HTTP (es. 400, 404, 500)
 * @param string $message    Messaggio di errore leggibile
 * @param array  $details    Dettagli aggiuntivi opzionali
 */
function sendError($statusCode, $message, $details = []) {
    $errorBody = [
        'error' => [
            'code'    => $statusCode,
            'message' => $message
        ]
    ];
    if (!empty($details)) {
        $errorBody['error']['details'] = $details;
    }
    sendResponse($statusCode, $errorBody);
}

/**
 * Legge e decodifica in array associativo il body JSON.
 *
 * @return array|null
 */
function getJsonInput() {
    $raw = file_get_contents('php://input');
    return json_decode($raw, true);
}
