<?php
// =============================================================
// api/Stats.php - Statistiche della Collezione Personale
// =============================================================

function handleStats($pdo, $method, $categoryId = null) {
    if ($method !== 'GET') {
        sendError(405, "Solo metodo GET consentito per le statistiche.");
    }

    $user = requireUserAuth($pdo);
    $userId = $user['id'];
    $catFilterSql = "";
    $params = ['uid' => $userId];
    // Filtro RESTful: usa l'id passato dalla rotta /stats/id
    if ($categoryId !== null) {
        $catFilterSql = " AND category_id = :cid";
        $params['cid'] = $categoryId;
    }

    $stats = [];

    // --- 1. OVERVIEW GENERALE E METRICHE AVANZATE ---
    $stmt1 = $pdo->prepare("
        SELECT 
            COUNT(*) as total_items, 
            IFNULL(ROUND(AVG(rating), 2), 0) as average_rating,
            IFNULL(ROUND(STDDEV(rating), 2), 0) as rating_stddev,
            SUM(CASE WHEN rating = 10 THEN 1 ELSE 0 END) as perfect_items,
            SUM(CASE WHEN image_url IS NOT NULL THEN 1 ELSE 0 END) as items_with_images,
            SUM(CASE WHEN created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) as items_last_30_days
        FROM items 
        WHERE user_id = :uid $catFilterSql
    ");
    $stmt1->execute($params);
    $general = $stmt1->fetch();
    
    $total = (int) $general['total_items'];
    $avg = (float) $general['average_rating'];
    $perfects = (int) $general['perfect_items'];
    
    // Nerd Metric: "Collector Score" (formula personalizzata per calcolare la potenza della collezione)
    $collectorScore = round(($total * $avg) + ($perfects * 50) + ((int)$general['items_with_images'] * 10));

    $stats['overview'] = [
        'scope' => $categoryId ? "Category ID $categoryId" : "All Collection",
        'collector_score' => $collectorScore,
        'total_items' => $total,
        'average_rating' => $avg,
        'grading_consistency' => (float) $general['rating_stddev'], // Quanto sono coerenti i voti (bassa STDDEV = voti tutti uguali)
        'perfect_items' => $perfects,
        'items_with_images' => (int) $general['items_with_images'],
        'items_last_30_days' => (int) $general['items_last_30_days']
    ];

    if (!$categoryId) {
        // Mostriamo il totale categorie solo se guardiamo l'intera collezione
        $stmt2 = $pdo->prepare("SELECT COUNT(*) as total FROM categories WHERE user_id = :uid");
        $stmt2->execute(['uid' => $userId]);
        $stats['overview']['total_categories'] = (int) $stmt2->fetch()['total'];

        // --- 2. DISTRIBUZIONE PER CATEGORIA ---
        $stmt3 = $pdo->prepare("
            SELECT c.id, c.name as category, COUNT(i.id) as count, IFNULL(ROUND(AVG(i.rating), 2), 0) as avg_rating
            FROM categories c
            LEFT JOIN items i ON c.id = i.category_id AND i.user_id = :uid1
            WHERE c.user_id = :uid2
            GROUP BY c.id
            ORDER BY count DESC, c.name ASC
        ");
        $stmt3->execute(['uid1' => $userId, 'uid2' => $userId]);
        $stats['by_category'] = $stmt3->fetchAll();
    }

    // --- 3. DISTRIBUZIONE VOTI (Curva di Gauss del collezionista) ---
    $stmt4 = $pdo->prepare("
        SELECT rating, COUNT(*) as count 
        FROM items 
        WHERE user_id = :uid $catFilterSql
        GROUP BY rating 
        ORDER BY rating DESC
    ");
    $stmt4->execute($params);
    $stats['rating_distribution'] = $stmt4->fetchAll();

    // --- 4. TIMELINE DELLE ACQUISIZIONI (Quanti oggetti per anno) ---
    $stmtTime = $pdo->prepare("
        SELECT YEAR(acquisition_date) as year, COUNT(*) as count
        FROM items
        WHERE user_id = :uid AND acquisition_date IS NOT NULL $catFilterSql
        GROUP BY YEAR(acquisition_date)
        ORDER BY year ASC
    ");
    $stmtTime->execute($params);
    $stats['acquisition_timeline'] = $stmtTime->fetchAll();

    // --- 5. TROFEI / RECORD PERSONALI ---
    $stats['records'] = [];
    
    $stmtTop = $pdo->prepare("SELECT id, name, rating FROM items WHERE user_id = :uid $catFilterSql ORDER BY rating DESC, created_at DESC LIMIT 1");
    $stmtTop->execute($params);
    $stats['records']['top_rated'] = $stmtTop->fetch() ?: null;

    $stmtOld = $pdo->prepare("SELECT id, name, acquisition_date FROM items WHERE user_id = :uid AND acquisition_date IS NOT NULL $catFilterSql ORDER BY acquisition_date ASC LIMIT 1");
    $stmtOld->execute($params);
    $stats['records']['oldest_acquisition'] = $stmtOld->fetch() ?: null;

    $stmtNew = $pdo->prepare("SELECT id, name, acquisition_date FROM items WHERE user_id = :uid AND acquisition_date IS NOT NULL $catFilterSql ORDER BY acquisition_date DESC LIMIT 1");
    $stmtNew->execute($params);
    $stats['records']['newest_acquisition'] = $stmtNew->fetch() ?: null;

    if (!$categoryId) {
        $stmtTopCat = $pdo->prepare("
            SELECT c.name, ROUND(AVG(i.rating), 2) as avg_rating
            FROM items i
            JOIN categories c ON i.category_id = c.id
            WHERE i.user_id = :uid
            GROUP BY c.id
            ORDER BY avg_rating DESC
            LIMIT 1
        ");
        $stmtTopCat->execute(['uid' => $userId]);
        $stats['records']['best_category'] = $stmtTopCat->fetch() ?: null;
    }

    sendResponse(200, $stats);
}
