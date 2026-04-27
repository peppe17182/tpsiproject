<?php
// =============================================================
// api/Stats.php - Statistiche della Collezione Personale
// =============================================================

function handleStats($pdo, $method) {
    if ($method !== 'GET') {
        sendError(405, "Solo metodo GET consentito per le statistiche.");
    }

    $user = requireUserAuth($pdo);
    $userId = $user['id'];

    $stats = [];

    // 1. Totale oggetti posseduti
    $stmt1 = $pdo->prepare("SELECT COUNT(*) as total FROM items WHERE user_id = :uid");
    $stmt1->execute(['uid' => $userId]);
    $stats['total_items'] = $stmt1->fetch()['total'];

    // 2. Rating medio
    $stmt2 = $pdo->prepare("SELECT ROUND(AVG(rating), 1) as avg_rating FROM items WHERE user_id = :uid");
    $stmt2->execute(['uid' => $userId]);
    $stats['average_rating'] = $stmt2->fetch()['avg_rating'];

    // 3. Oggetti divisi per categoria (utile per grafici a torta)
    $stmt3 = $pdo->prepare(
        "SELECT c.name as category, COUNT(i.id) as count 
         FROM items i 
         JOIN categories c ON i.category_id = c.id 
         WHERE i.user_id = :uid 
         GROUP BY c.id"
    );
    $stmt3->execute(['uid' => $userId]);
    $stats['by_category'] = $stmt3->fetchAll();

    // 4. L'oggetto con il rating piu' alto (preferito)
    $stmt4 = $pdo->prepare(
        "SELECT id, name, rating, image_url 
         FROM items 
         WHERE user_id = :uid 
         ORDER BY rating DESC, created_at DESC 
         LIMIT 1"
    );
    $stmt4->execute(['uid' => $userId]);
    $stats['top_item'] = $stmt4->fetch() ?: null;

    sendResponse(200, $stats);
}
