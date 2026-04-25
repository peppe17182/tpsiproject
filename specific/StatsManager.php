<?php
// =============================================================
// specific/StatsManager.php - Endpoint per statistiche e grafici
//
// Fornisce dati aggregati pronti per Pie Charts e Bar Charts in Flutter.
// URI:
//   GET /stats/rankings   -> Top 10 oggetti per rating (Bar Chart)
//   GET /stats/categories -> Conteggio oggetti per categoria (Pie Chart)
// =============================================================

function handleStats($method, $type) {
    if ($method !== 'GET') {
        sendResponse(405, ['error' => 'Metodo non consentito. Supportato: GET.']);
    }

    $pdo = getDbConnection();

    switch ($type) {

        case 'rankings':
            // Top 10 oggetti ordinati per rating decrescente.
            // Include il nome della categoria per contesto nel grafico.
            $sql = "SELECT i.id, i.name, i.rating, c.name AS category
                    FROM items i
                    JOIN categories c ON i.category_id = c.id
                    ORDER BY i.rating DESC
                    LIMIT 10";
            $stmt = $pdo->query($sql);
            sendResponse(200, $stmt->fetchAll());
            break;

        case 'categories':
            // Conteggio oggetti per categoria (dati per Pie Chart).
            // Formato: [{label, value}, ...] pronto per Flutter.
            $sql = "SELECT c.name AS label, COUNT(i.id) AS value
                    FROM categories c
                    LEFT JOIN items i ON c.id = i.category_id
                    GROUP BY c.id, c.name
                    ORDER BY value DESC";
            $stmt = $pdo->query($sql);
            sendResponse(200, $stmt->fetchAll());
            break;

        default:
            sendResponse(400, [
                'error' => 'Tipo di statistica non valido. Usa: /stats/rankings o /stats/categories.'
            ]);
            break;
    }
}
