<?php
// =============================================================
// api/Item.php - Gestione Oggetti (Rigorosamente Privati)
// =============================================================

function handleItems($pdo, $method, $id = null) {
    // Tutte le operazioni sugli item richiedono il Token Utente
    $user = requireUserAuth($pdo);
    $userId = $user['id'];

    switch ($method) {
        case 'GET':
            if ($id !== null) {
                // Dettaglio singolo oggetto
                $stmt = $pdo->prepare("SELECT * FROM items WHERE id = :id AND user_id = :uid");
                $stmt->execute(['id' => $id, 'uid' => $userId]);
                $item = $stmt->fetch();
                
                if ($item) {
                    sendResponse(200, $item);
                } else {
                    sendError(404, "Oggetto non trovato o non autorizzato.");
                }
            } else {
                // Lista paginata e filtrabile
                $page = isset($_GET['page']) ? max(1, (int)$_GET['page']) : 1;
                $limit = isset($_GET['limit']) ? max(1, (int)$_GET['limit']) : 20;
                $offset = ($page - 1) * $limit;
                
                $search = $_GET['search'] ?? null;
                
                $query = "SELECT id, name, rating, image_url, category_id FROM items WHERE user_id = :uid";
                $params = ['uid' => $userId];
                
                if ($search) {
                    $query .= " AND name LIKE :search";
                    $params['search'] = '%' . $search . '%';
                }
                
                $query .= " ORDER BY created_at DESC LIMIT " . (int)$limit . " OFFSET " . (int)$offset;
                
                // PDO non supporta il binding diretto di LIMIT/OFFSET con execute() in alcuni fetch mode senza bindValue, 
                // ma concatenarli castati a intero è sicuro contro SQL injection.
                $stmt = $pdo->prepare($query);
                $stmt->execute($params);
                $items = $stmt->fetchAll();
                
                // Recupero totale per la paginazione
                $countQuery = "SELECT COUNT(*) as total FROM items WHERE user_id = :uid";
                if ($search) {
                    $countQuery .= " AND name LIKE :search";
                }
                $countStmt = $pdo->prepare($countQuery);
                $countStmt->execute($params);
                $total = $countStmt->fetch()['total'];
                
                sendResponse(200, [
                    'data' => $items,
                    'meta' => [
                        'current_page' => $page,
                        'per_page'     => $limit,
                        'total_items'  => $total,
                        'total_pages'  => ceil($total / $limit)
                    ]
                ]);
            }
            break;

        case 'POST':
            $data = getJsonInput();
            if (!isset($data['name'], $data['category_id'])) {
                sendError(400, "Campi obbligatori mancanti: name, category_id.");
            }
            $rating = $data['rating'] ?? 1;
            
            // Verifica che la categoria appartenga all'utente
            $checkCat = $pdo->prepare("SELECT id FROM categories WHERE id = :cid AND user_id = :uid");
            $checkCat->execute(['cid' => $data['category_id'], 'uid' => $userId]);
            if (!$checkCat->fetch()) {
                sendError(403, "Categoria non valida o non appartenente a te.");
            }
            
            $stmt = $pdo->prepare(
                "INSERT INTO items (name, description, rating, acquisition_date, image_url, user_id, category_id)
                 VALUES (:name, :desc, :rating, :date, :img, :uid, :cid)"
            );
            
            // user_id è SEMPRE l'id dell'utente loggato, per sicurezza
            $stmt->execute([
                'name'   => trim($data['name']),
                'desc'   => $data['description'] ?? null,
                'rating' => $rating,
                'date'   => $data['acquisition_date'] ?? null,
                'img'    => $data['image_url'] ?? null,
                'uid'    => $userId,
                'cid'    => $data['category_id']
            ]);
            
            sendResponse(201, [
                'message' => 'Oggetto creato con successo nella tua collezione.',
                'id'      => (int) $pdo->lastInsertId()
            ]);
            break;

        case 'PUT':
        case 'PATCH':
            if ($id === null) {
                sendError(400, "ID mancante.");
            }
            $data = getJsonInput();
            if (empty($data)) {
                sendError(400, "Nessun dato fornito.");
            }
            
            // Costruzione dinamica dell'UPDATE
            $allowed = ['name','description','rating','acquisition_date','category_id'];
            $sets   = [];
            $params = ['id' => $id, 'uid' => $userId];
            
            foreach ($allowed as $field) {
                if (array_key_exists($field, $data)) {
                    $sets[]          = "$field = :$field";
                    $params[$field]  = $data[$field];
                }
            }
            
            if (empty($sets)) {
                sendError(400, "Nessun campo valido da aggiornare.");
            }
            
            // Verifica che la categoria, se presente, appartenga all'utente
            if (array_key_exists('category_id', $data)) {
                $checkCat = $pdo->prepare("SELECT id FROM categories WHERE id = :cid AND user_id = :uid");
                $checkCat->execute(['cid' => $data['category_id'], 'uid' => $userId]);
                if (!$checkCat->fetch()) {
                    sendError(403, "La nuova categoria non e' valida o non ti appartiene.");
                }
            }
            
            // IMPORTANTE: si aggiorna solo se l'oggetto appartiene all'utente loggato
            $sql = "UPDATE items SET " . implode(', ', $sets) . " WHERE id = :id AND user_id = :uid";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
            
            if ($stmt->rowCount() > 0) {
                sendResponse(200, ['message' => 'Oggetto aggiornato con successo.']);
            } else {
                sendError(404, "Oggetto non trovato, non autorizzato o nessun dato modificato.");
            }
            break;

        case 'DELETE':
            if ($id === null) {
                sendError(400, "ID mancante.");
            }
            // IMPORTANTE: si elimina solo se l'oggetto appartiene all'utente loggato
            $stmt = $pdo->prepare("DELETE FROM items WHERE id = :id AND user_id = :uid");
            $stmt->execute(['id' => $id, 'uid' => $userId]);
            
            if ($stmt->rowCount() > 0) {
                sendResponse(200, ['message' => 'Oggetto rimosso dalla tua collezione.']);
            } else {
                sendError(404, "Oggetto non trovato o non autorizzato.");
            }
            break;

        default:
            sendError(405, "Metodo non consentito.");
            break;
    }
}
