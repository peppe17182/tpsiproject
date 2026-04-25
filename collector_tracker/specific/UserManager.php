<?php
// =============================================================
// specific/UserManager.php - Gestione della risorsa Utenti
//
// Operazioni consentite: solo Read (GET).
// URI supportati:
//   GET /users       -> array JSON con dati parziali (id, username)
//   GET /users/{id}  -> oggetto JSON con dati completi
// =============================================================

/**
 * Gestisce le richieste sulla risorsa Utenti.
 *
 * @param string      $method Metodo HTTP della richiesta
 * @param string|null $id     ID dell'utente (se presente nell'URL)
 */
function handleUsers($method, $id) {
    if ($method !== 'GET') {
        sendResponse(405, ['error' => 'Metodo non consentito. Supportato: GET.']);
    }

    $pdo = getDbConnection();

    if ($id !== null) {
        // --- Dettaglio singolo utente (dati completi) ---
        $stmt = $pdo->prepare("SELECT id, username, email, created_at FROM users WHERE id = :id");
        $stmt->execute(['id' => $id]);
        $user = $stmt->fetch();

        if ($user) {
            sendResponse(200, $user);
        } else {
            sendResponse(404, ['error' => 'Utente non trovato.']);
        }
    } else {
        // --- Lista di tutti gli utenti (dati parziali) ---
        $stmt = $pdo->query("SELECT id, username FROM users");
        $users = $stmt->fetchAll();
        sendResponse(200, $users);
    }
}
