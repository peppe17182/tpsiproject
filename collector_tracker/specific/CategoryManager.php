<?php
// =============================================================
// specific/CategoryManager.php - Gestione della risorsa Categorie
//
// Operazioni: Read (GET), Create (POST), Delete (DELETE).
// URI:
//   GET    /categories       -> array JSON (dati parziali)
//   GET    /categories/{id}  -> oggetto JSON (dati completi)
//   POST   /categories       -> crea nuova categoria
//   DELETE /categories/{id}  -> elimina categoria
// =============================================================

function handleCategories($method, $id) {
    $pdo = getDbConnection();

    switch ($method) {

        case 'GET':
            if ($id !== null) {
                $stmt = $pdo->prepare(
                    "SELECT id, name, description, created_at FROM categories WHERE id = :id"
                );
                $stmt->execute(['id' => $id]);
                $cat = $stmt->fetch();
                if ($cat) {
                    sendResponse(200, $cat);
                } else {
                    sendResponse(404, ['error' => 'Categoria non trovata.']);
                }
            } else {
                $stmt = $pdo->query("SELECT id, name FROM categories");
                sendResponse(200, $stmt->fetchAll());
            }
            break;

        case 'POST':
            $data = getJsonInput();
            if (!isset($data['name']) || trim($data['name']) === '') {
                sendResponse(400, ['error' => 'Campo obbligatorio mancante: name.']);
            }
            $stmt = $pdo->prepare(
                "INSERT INTO categories (name, description) VALUES (:name, :desc)"
            );
            $stmt->execute([
                'name' => trim($data['name']),
                'desc' => $data['description'] ?? null
            ]);
            sendResponse(201, [
                'message' => 'Categoria creata con successo.',
                'id'      => (int) $pdo->lastInsertId()
            ]);
            break;

        case 'DELETE':
            if ($id === null) {
                sendResponse(400, ['error' => 'ID mancante. URI: /categories/{id}']);
            }
            $stmt = $pdo->prepare("DELETE FROM categories WHERE id = :id");
            $stmt->execute(['id' => $id]);
            if ($stmt->rowCount() > 0) {
                sendResponse(200, ['message' => 'Categoria eliminata.']);
            } else {
                sendResponse(404, ['error' => 'Categoria non trovata.']);
            }
            break;

        default:
            sendResponse(405, ['error' => 'Metodo non consentito. Supportati: GET, POST, DELETE.']);
            break;
    }
}
