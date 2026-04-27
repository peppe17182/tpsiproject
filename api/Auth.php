<?php
// =============================================================
// api/Auth.php - Autenticazione (Registrazione e Login)
// =============================================================

function handleAuth($pdo, $method, $action) {
    if ($method === 'POST' && $action === 'register') {
        register($pdo);
    } elseif ($method === 'POST' && $action === 'login') {
        login($pdo);
    } elseif ($method === 'GET' && $action === 'me') {
        // me() richiede autenticazione utente
        $user = requireUserAuth($pdo);
        sendResponse(200, ['user' => $user]);
    } else {
        sendError(404, "Endpoint Auth non trovato o metodo non consentito.");
    }
}

function register($pdo) {
    $data = getJsonInput();
    if (!isset($data['username'], $data['email'], $data['password'])) {
        sendError(400, "Campi obbligatori mancanti: username, email, password.");
    }

    $hash = password_hash(trim($data['password']), PASSWORD_BCRYPT);

    try {
        $stmt = $pdo->prepare(
            "INSERT INTO users (username, email, password_hash) VALUES (:username, :email, :hash)"
        );
        $stmt->execute([
            'username' => trim($data['username']),
            'email'    => trim($data['email']),
            'hash'     => $hash
        ]);
        
        sendResponse(201, [
            'message' => 'Registrazione completata. Ora puoi effettuare il login.',
            'id'      => (int) $pdo->lastInsertId()
        ]);
    } catch (PDOException $e) {
        // Gestione errore per duplicati (1062 = Duplicate entry)
        if ($e->errorInfo[1] == 1062) {
            sendError(409, "Username o email gia' in uso.");
        }
        sendError(500, "Errore durante la registrazione: " . $e->getMessage());
    }
}

function login($pdo) {
    $data = getJsonInput();
    if (!isset($data['email'], $data['password'])) {
        sendError(400, "Campi obbligatori mancanti: email, password.");
    }

    $stmt = $pdo->prepare("SELECT id, username, email, password_hash FROM users WHERE email = :email");
    $stmt->execute(['email' => trim($data['email'])]);
    $user = $stmt->fetch();

    if ($user && password_verify($data['password'], $user['password_hash'])) {
        // Genera un token forte
        $token = bin2hex(random_bytes(32));
        
        // Salva il token
        $update = $pdo->prepare("UPDATE users SET api_token = :token WHERE id = :id");
        $update->execute(['token' => $token, 'id' => $user['id']]);

        // Restituisci token e dati profilo base
        unset($user['password_hash']);
        sendResponse(200, [
            'message' => 'Login completato con successo.',
            'token'   => $token,
            'user'    => $user
        ]);
    } else {
        sendError(401, "Credenziali non valide.");
    }
}
