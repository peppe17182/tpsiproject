<?php
// =============================================================
// specific/ItemManager.php - Gestione della risorsa Oggetti
//
// CRUD completo + PATCH (aggiornamento parziale).
// URI supportati:
//   GET    /items                -> lista (dati parziali)
//   GET    /items/{id}           -> dettaglio (dati completi)
//   GET    /items/category/{id}  -> URL composta: oggetti per categoria
//   GET    /items/user/{id}      -> URL composta: oggetti per utente
//   POST   /items                -> crea nuovo oggetto
//   PUT    /items/{id}           -> aggiornamento totale (sostituzione)
//   PATCH  /items/{id}           -> aggiornamento parziale
//   DELETE /items/{id}           -> elimina oggetto
// =============================================================

function handleItems($method, $param1, $param2) {
    $pdo = getDbConnection();

    // --- Gestione URL composte: /items/category/{id} o /items/user/{id} ---
    if ($param1 !== null && !is_numeric($param1)) {
        if ($method !== 'GET') {
            sendResponse(405, ['error' => 'Solo GET consentito su URI composti.']);
        }
        handleItemsComposed($pdo, $param1, $param2);
        return;
    }

    $id = $param1; // ID numerico dell'oggetto, oppure null

    switch ($method) {

        case 'GET':
            if ($id !== null) {
                // Dettaglio singolo oggetto (dati completi)
                $stmt = $pdo->prepare("SELECT * FROM items WHERE id = :id");
                $stmt->execute(['id' => $id]);
                $item = $stmt->fetch();
                if ($item) {
                    sendResponse(200, $item);
                } else {
                    sendResponse(404, ['error' => 'Oggetto non trovato.']);
                }
            } else {
                // Lista oggetti (dati parziali: id, name, rating, image_url)
                // Filtro opzionale via query string: ?category_id=X o ?user_id=X
                $catId  = $_GET['category_id'] ?? null;
                $userId = $_GET['user_id'] ?? null;

                if ($catId) {
                    $stmt = $pdo->prepare(
                        "SELECT id, name, rating, image_url FROM items WHERE category_id = :cid"
                    );
                    $stmt->execute(['cid' => $catId]);
                } elseif ($userId) {
                    $stmt = $pdo->prepare(
                        "SELECT id, name, rating, image_url FROM items WHERE user_id = :uid"
                    );
                    $stmt->execute(['uid' => $userId]);
                } else {
                    $stmt = $pdo->query("SELECT id, name, rating, image_url FROM items");
                }
                sendResponse(200, $stmt->fetchAll());
            }
            break;

        case 'POST':
            $data = getJsonInput();
            if (!isset($data['name'], $data['user_id'], $data['category_id'])) {
                sendResponse(400, [
                    'error' => 'Campi obbligatori mancanti: name, user_id, category_id.'
                ]);
            }
            $rating = $data['rating'] ?? 1;
            if ($rating < 1 || $rating > 10) {
                sendResponse(400, ['error' => 'Il rating deve essere compreso tra 1 e 10.']);
            }
            $stmt = $pdo->prepare(
                "INSERT INTO items (name, description, rating, acquisition_date, image_url, user_id, category_id)
                 VALUES (:name, :desc, :rating, :date, :img, :uid, :cid)"
            );
            $stmt->execute([
                'name'   => trim($data['name']),
                'desc'   => $data['description'] ?? null,
                'rating' => $rating,
                'date'   => $data['acquisition_date'] ?? null,
                'img'    => $data['image_url'] ?? null,
                'uid'    => $data['user_id'],
                'cid'    => $data['category_id']
            ]);
            sendResponse(201, [
                'message' => 'Oggetto creato con successo.',
                'id'      => (int) $pdo->lastInsertId()
            ]);
            break;

        case 'PUT':
            if ($id === null) {
                sendResponse(400, ['error' => 'ID mancante. URI: /items/{id}']);
            }
            $data = getJsonInput();
            if (!isset($data['name'], $data['user_id'], $data['category_id'])) {
                sendResponse(400, [
                    'error' => 'PUT richiede tutti i campi: name, user_id, category_id.'
                ]);
            }
            $rating = $data['rating'] ?? 1;
            if ($rating < 1 || $rating > 10) {
                sendResponse(400, ['error' => 'Il rating deve essere compreso tra 1 e 10.']);
            }
            $stmt = $pdo->prepare(
                "UPDATE items SET name = :name, description = :desc, rating = :rating,
                 acquisition_date = :date, image_url = :img, user_id = :uid, category_id = :cid
                 WHERE id = :id"
            );
            $stmt->execute([
                'id'     => $id,
                'name'   => trim($data['name']),
                'desc'   => $data['description'] ?? null,
                'rating' => $rating,
                'date'   => $data['acquisition_date'] ?? null,
                'img'    => $data['image_url'] ?? null,
                'uid'    => $data['user_id'],
                'cid'    => $data['category_id']
            ]);
            if ($stmt->rowCount() > 0) {
                sendResponse(200, ['message' => 'Oggetto aggiornato (PUT).']);
            } else {
                sendResponse(404, ['error' => 'Oggetto non trovato.']);
            }
            break;

        case 'PATCH':
            if ($id === null) {
                sendResponse(400, ['error' => 'ID mancante. URI: /items/{id}']);
            }
            $data = getJsonInput();
            if (empty($data)) {
                sendResponse(400, ['error' => 'Nessun dato fornito per PATCH.']);
            }
            // Costruzione dinamica sicura della query UPDATE
            $allowed = ['name','description','rating','acquisition_date','image_url','user_id','category_id'];
            $sets   = [];
            $params = ['id' => $id];
            foreach ($allowed as $field) {
                if (array_key_exists($field, $data)) {
                    $sets[]          = "$field = :$field";
                    $params[$field]  = $data[$field];
                }
            }
            if (empty($sets)) {
                sendResponse(400, ['error' => 'Nessun campo valido nel body JSON.']);
            }
            if (isset($params['rating']) && ($params['rating'] < 1 || $params['rating'] > 10)) {
                sendResponse(400, ['error' => 'Il rating deve essere compreso tra 1 e 10.']);
            }
            $sql = "UPDATE items SET " . implode(', ', $sets) . " WHERE id = :id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
            if ($stmt->rowCount() > 0) {
                sendResponse(200, ['message' => 'Oggetto aggiornato parzialmente (PATCH).']);
            } else {
                sendResponse(404, ['error' => 'Oggetto non trovato o nessun dato modificato.']);
            }
            break;

        case 'DELETE':
            if ($id === null) {
                sendResponse(400, ['error' => 'ID mancante. URI: /items/{id}']);
            }
            $stmt = $pdo->prepare("DELETE FROM items WHERE id = :id");
            $stmt->execute(['id' => $id]);
            if ($stmt->rowCount() > 0) {
                sendResponse(200, ['message' => 'Oggetto eliminato.']);
            } else {
                sendResponse(404, ['error' => 'Oggetto non trovato.']);
            }
            break;

        default:
            sendResponse(405, [
                'error' => 'Metodo non consentito. Supportati: GET, POST, PUT, PATCH, DELETE.'
            ]);
            break;
    }
}

/**
 * Gestisce le URL composte per la risorsa Oggetti.
 *   /items/category/{id} -> oggetti filtrati per categoria
 *   /items/user/{id}     -> oggetti filtrati per utente
 */
function handleItemsComposed($pdo, $subResource, $subId) {
    if ($subId === null) {
        sendResponse(400, ['error' => 'ID mancante nell\'URI composto.']);
    }

    switch ($subResource) {
        case 'category':
            $stmt = $pdo->prepare(
                "SELECT id, name, rating, image_url FROM items WHERE category_id = :cid"
            );
            $stmt->execute(['cid' => $subId]);
            sendResponse(200, $stmt->fetchAll());
            break;

        case 'user':
            $stmt = $pdo->prepare(
                "SELECT id, name, rating, image_url FROM items WHERE user_id = :uid"
            );
            $stmt->execute(['uid' => $subId]);
            sendResponse(200, $stmt->fetchAll());
            break;

        default:
            sendResponse(400, [
                'error' => "Sotto-risorsa '$subResource' non valida. Usa: category, user."
            ]);
            break;
    }
}
