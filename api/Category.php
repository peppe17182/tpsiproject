<?php
// =============================================================
// api/Category.php - Gestione Categorie
// =============================================================

function handleCategories($pdo, $method, $id = null) {
    // Richiediamo SEMPRE l'utente loggato: le categorie sono private
    $user = requireUserAuth($pdo);
    $userId = $user['id'];

    switch ($method) {
        case 'GET':
            if ($id !== null) {
                // Dati completi per la singola istanza (solo se propria)
                $stmt = $pdo->prepare("SELECT id, name, description, created_at FROM categories WHERE id = :id AND user_id = :uid");
                $stmt->execute(['id' => $id, 'uid' => $userId]);
                $cat = $stmt->fetch();
                if ($cat) {
                    sendResponse(200, $cat);
                } else {
                    sendError(404, "Categoria non trovata o non autorizzata.");
                }
            } else {
                // Dati parziali per l'array di tutte le istanze (solo le proprie)
                $stmt = $pdo->prepare("SELECT id, name FROM categories WHERE user_id = :uid");
                $stmt->execute(['uid' => $userId]);
                sendResponse(200, $stmt->fetchAll());
            }
            break;

        case 'POST':
            $data = getJsonInput();
            if (!isset($data['name'])) {
                sendError(400, "Campo obbligatorio mancante: name.");
            }
            
            $stmt = $pdo->prepare("INSERT INTO categories (name, description, user_id) VALUES (:name, :desc, :uid)");
            try {
                $stmt->execute([
                    'name' => trim($data['name']),
                    'desc' => $data['description'] ?? null,
                    'uid'  => $userId
                ]);
                sendResponse(201, [
                    'message' => 'Categoria creata con successo.',
                    'id'      => (int) $pdo->lastInsertId()
                ]);
            } catch (PDOException $e) {
                if ($e->errorInfo[1] == 1062) {
                    sendError(409, "Hai già creato una categoria con questo nome.");
                }
                sendError(500, "Errore nella creazione della categoria: " . $e->getMessage());
            }
            break;

        case 'PUT':
        case 'PATCH':
            if ($id === null) {
                sendError(400, "ID mancante sulla rotta /categories/valoreid.");
            }
            $data = getJsonInput();
            if (empty($data)) {
                sendError(400, "Nessun dato fornito per l'aggiornamento.");
            }
            
            $allowed = ['name', 'description'];
            $sets = [];
            $params = ['id' => $id, 'uid' => $userId];
            
            foreach ($allowed as $field) {
                if (array_key_exists($field, $data)) {
                    $sets[] = "$field = :$field";
                    $params[$field] = $data[$field];
                }
            }
            
            if (empty($sets)) {
                sendError(400, "Nessun campo valido da aggiornare.");
            }
            
            try {
                $sql = "UPDATE categories SET " . implode(', ', $sets) . " WHERE id = :id AND user_id = :uid";
                $stmt = $pdo->prepare($sql);
                $stmt->execute($params);
                
                if ($stmt->rowCount() > 0) {
                    sendResponse(200, ['message' => 'Categoria aggiornata con successo.']);
                } else {
                    sendError(404, "Categoria non trovata, non autorizzata o nessun dato modificato.");
                }
            } catch (PDOException $e) {
                if ($e->errorInfo[1] == 1062) {
                    sendError(409, "Hai già un'altra categoria con questo nome.");
                }
                sendError(500, "Errore durante l'aggiornamento.");
            }
            break;

        case 'DELETE':
            if ($id === null) {
                sendError(400, "ID mancante sulla rotta /categories/valoreid.");
            }
            
            // L'eliminazione in cascata eliminerà anche tutti gli item associati
            $stmt = $pdo->prepare("DELETE FROM categories WHERE id = :id AND user_id = :uid");
            $stmt->execute(['id' => $id, 'uid' => $userId]);
            
            if ($stmt->rowCount() > 0) {
                sendResponse(200, ['message' => 'Categoria eliminata con successo (insieme a tutti gli oggetti associati).']);
            } else {
                sendError(404, "Categoria non trovata o non autorizzata.");
            }
            break;

        default:
            sendError(405, "Metodo non consentito.");
            break;
    }
}
