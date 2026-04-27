<?php
// =============================================================
// api/Upload.php - Gestione Caricamento Immagini
// =============================================================

function handleUpload($pdo, $method, $itemId = null) {
    if ($method !== 'POST' && $method !== 'DELETE') {
        sendError(405, "Solo POST o DELETE consentiti per l'upload.");
    }

    // Richiede sempre autenticazione per sicurezza
    $user = requireUserAuth($pdo);
    $userId = $user['id'];

    if ($itemId === null) {
        sendError(400, "ID dell'oggetto mancante. Usa /upload/{item_id}");
    }

    // Verifica che l'oggetto esista e appartenga all'utente loggato
    $stmt = $pdo->prepare("SELECT id, image_url FROM items WHERE id = :id AND user_id = :uid");
    $stmt->execute(['id' => $itemId, 'uid' => $userId]);
    $item = $stmt->fetch();

    if (!$item) {
        sendError(404, "Oggetto non trovato o non autorizzato.");
    }

    if ($method === 'DELETE') {
        if ($item['image_url']) {
            $filepath = __DIR__ . '/..' . $item['image_url']; // image_url es: /uploads/items/...
            if (file_exists($filepath)) {
                unlink($filepath);
            }
            
            // Rimuove il riferimento dal database
            $update = $pdo->prepare("UPDATE items SET image_url = NULL WHERE id = :id");
            $update->execute(['id' => $itemId]);
            
            sendResponse(200, ['message' => 'Immagine eliminata dall\'oggetto con successo.']);
        } else {
            sendError(404, "Nessuna immagine associata a questo oggetto.");
        }
        exit;
    }

    // --- Gestione POST ---
    if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
        sendError(400, "Nessun file caricato o errore durante l'upload.");
    }

    $file = $_FILES['image'];
    
    // Controlli base di sicurezza
    $allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    if (!in_array($mime, $allowedMimes)) {
        sendError(400, "Formato file non supportato. Usa JPG, PNG o WEBP.");
    }

    // Limite dimensione (es. 5MB)
    if ($file['size'] > 5 * 1024 * 1024) {
        sendError(400, "Il file è troppo grande (Max 5MB).");
    }

    // Generazione nome univoco per evitare sovrascritture
    $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = uniqid('item_' . $itemId . '_', true) . '.' . $ext;
    
    $uploadDir = __DIR__ . '/../uploads/items/';
    if (!is_dir($uploadDir)) {
        mkdir($uploadDir, 0755, true);
    }
    
    $destination = $uploadDir . $filename;

    if (move_uploaded_file($file['tmp_name'], $destination)) {
        
        // Se c'era una vecchia immagine, eliminiamola per non intasare il server
        if ($item['image_url']) {
            $oldFile = __DIR__ . '/..' . $item['image_url'];
            if (file_exists($oldFile)) {
                unlink($oldFile);
            }
        }

        // Restituisce un URL relativo che il frontend può usare
        $publicUrl = '/uploads/items/' . $filename;
        
        // Aggiorna automaticamente il database dell'oggetto
        $update = $pdo->prepare("UPDATE items SET image_url = :url WHERE id = :id");
        $update->execute(['url' => $publicUrl, 'id' => $itemId]);

        sendResponse(201, [
            'message'   => 'Immagine caricata e associata all\'oggetto con successo.',
            'image_url' => $publicUrl
        ]);
    } else {
        sendError(500, "Errore durante il salvataggio del file sul server.");
    }
}

