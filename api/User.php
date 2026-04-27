<?php
// =============================================================
// api/User.php - Gestione Utenti
// =============================================================

function handleUser($pdo, $method, $id = null) {
    // Le operazioni di lettura possono essere pubbliche (pur con API Key globale) o richiedere token.
    // Richiediamo il token per una maggiore sicurezza.
    $user = requireUserAuth($pdo);
    $userId = $user['id'];

    switch ($method) {
        case 'GET':
            if ($id !== null) {
                // Dati completi dell'istanza (risorsa utente)
                $stmt = $pdo->prepare("SELECT id, username, email, created_at FROM users WHERE id = :id");
                $stmt->execute(['id' => $id]);
                $targetUser = $stmt->fetch();
                
                if ($targetUser) {
                    sendResponse(200, $targetUser);
                } else {
                    sendError(404, "Utente non trovato.");
                }
            } else {
                // Dati parziali per l'array di tutte le istanze (esclude email e created_at per la lista)
                $stmt = $pdo->query("SELECT id, username FROM users ORDER BY id ASC");
                sendResponse(200, $stmt->fetchAll());
            }
            break;
            
        case 'PUT':
        case 'PATCH':
            // Puoi aggiornare solo il TUO profilo
            if ($id === null || (int)$id !== (int)$userId) {
                sendError(403, "Azione non autorizzata. Puoi modificare solo il tuo profilo su /users/" . $userId);
            }
            
            $data = getJsonInput();
            if (empty($data)) {
                sendError(400, "Nessun dato fornito per l'aggiornamento.");
            }
            
            $allowed = ['username', 'email'];
            $sets   = [];
            $params = ['id' => $userId];
            
            foreach ($allowed as $field) {
                if (array_key_exists($field, $data)) {
                    $sets[]          = "$field = :$field";
                    $params[$field]  = trim($data[$field]);
                }
            }
            
            if (!empty($data['password'])) {
                $sets[] = "password_hash = :hash";
                $params['hash'] = password_hash(trim($data['password']), PASSWORD_BCRYPT);
            }
            
            if (empty($sets)) {
                sendError(400, "Nessun campo valido da aggiornare.");
            }
            
            try {
                $sql = "UPDATE users SET " . implode(', ', $sets) . " WHERE id = :id";
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                
                sendResponse(200, ['message' => 'Profilo aggiornato con successo.']);
            } catch (PDOException $e) {
                if ($e->errorInfo[1] == 1062) {
                    sendError(409, "Username o email gia' in uso da un altro utente.");
                }
                sendError(500, "Errore durante l'aggiornamento: " . $e->getMessage());
            }
            break;
            
        case 'DELETE':
            // Eliminazione: deve essere su /risorsa/valoreid
            if ($id === null) {
                sendError(400, "ID mancante sulla rotta /users/valoreid.");
            }
            
            // Puoi eliminare solo il TUO profilo
            if ((int)$id !== (int)$userId) {
                sendError(403, "Azione non autorizzata. Puoi eliminare solo il tuo account.");
            }

            $stmt = $pdo->prepare("DELETE FROM users WHERE id = :id");
            $stmt->execute(['id' => $userId]);
            
            sendResponse(200, ['message' => 'Account eliminato definitivamente.']);
            break;

        default:
            sendError(405, "Metodo non consentito.");
            break;
    }
}
