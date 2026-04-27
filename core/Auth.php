<?php
// =============================================================
// core/Auth.php - Autenticazione Globale e Per-Utente
// =============================================================


/**
 * Autentica l'utente tramite Token personale (Livello 2).
 * Da chiamare negli endpoint strettamente privati (es. get/post items).
 * 
 * @param PDO $pdo
 * @return array L'array associativo con i dati dell'utente loggato.
 */
function requireUserAuth($pdo) {
    $headers = getallheaders();
    $authHeader = null;

    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
    } elseif (isset($headers['authorization'])) {
        $authHeader = $headers['authorization'];
    }

    if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        sendError(401, "Manca o e' malformato l'header Authorization: Bearer <token>");
    }

    $token = $matches[1];

    $stmt = $pdo->prepare("SELECT id, username, email FROM users WHERE api_token = :token");
    $stmt->execute(['token' => $token]);
    $user = $stmt->fetch();

    if (!$user) {
        sendError(401, "Token utente non valido o scaduto.");
    }

    return $user;
}
