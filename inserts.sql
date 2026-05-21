

INSERT INTO `categories` (`id`, `name`, `description`, `user_id`, `created_at`) VALUES
(1, 'spider-man', 'bolle', 1, '2026-05-12 09:54:15'),
(2, 'Collezione Rara', 'Categoria generica per Collezione Rara', 2, '2026-05-14 08:48:50'),
(3, 'Preferiti', 'Categoria generica per Preferiti', 2, '2026-05-14 08:48:50'),
(4, 'Collezione Rara', 'Categoria generica per Collezione Rara', 3, '2026-05-14 08:48:51'),
(5, 'Preferiti', 'Categoria generica per Preferiti', 3, '2026-05-14 08:48:51'),
(6, 'Collezione Rara', 'Categoria generica per Collezione Rara', 4, '2026-05-14 08:48:51'),
(7, 'Preferiti', 'Categoria generica per Preferiti', 4, '2026-05-14 08:48:51'),
(8, 'Collezione Rara', 'Categoria generica per Collezione Rara', 5, '2026-05-14 08:48:51'),
(9, 'Preferiti', 'Categoria generica per Preferiti', 5, '2026-05-14 08:48:51'),
(10, 'Collezione mario', 'Categoria creata da script', 2, '2026-05-14 09:35:36'),
(11, 'Collezione luigi', 'Categoria creata da script', 3, '2026-05-14 09:35:38'),
(12, 'Collezione anna', 'Categoria creata da script', 4, '2026-05-14 09:35:39'),
(13, 'Collezione sofia', 'Categoria creata da script', 5, '2026-05-14 09:45:43');


INSERT INTO `items` (`id`, `name`, `description`, `rating`, `acquisition_date`, `image_url`, `user_id`, `category_id`, `created_at`) VALUES
(1, 'spider', '', 5, NULL, '/uploads/items/item_1_6a0581fbc99581.20148755.png', 1, 1, '2026-05-12 09:54:36'),
(2, 'spiderjackson', 'aaaa', 4, '2025-10-20', '/uploads/items/item_2_6a0581f4933050.23396453.png', 1, 1, '2026-05-12 09:55:58'),
(3, 'spider', 'aaaa', 5, '2020-05-14', '/uploads/items/item_3_6a058189b9ddc9.45355772.png', 1, 1, '2026-05-12 15:01:43'),
(28, 'Oggetto 1 di mario', 'Oggetto con immagine caricata via API', 3, '2025-01-05', '/uploads/items/item_28_6a0597699bead5.85079551.jpg', 2, 10, '2026-05-14 09:35:36'),
(29, 'Oggetto 2 di mario', 'Oggetto con immagine caricata via API', 4, '2025-01-14', '/uploads/items/item_29_6a059769d8fa12.76473427.jpg', 2, 10, '2026-05-14 09:35:37'),
(30, 'Oggetto 3 di mario', 'Oggetto con immagine caricata via API', 5, '2024-09-22', '/uploads/items/item_30_6a05976a2471a1.30915422.jpg', 2, 10, '2026-05-14 09:35:37'),
(31, 'Oggetto 4 di mario', 'Oggetto con immagine caricata via API', 1, '2025-07-03', '/uploads/items/item_31_6a05976a5e3fd4.92103201.jpg', 2, 10, '2026-05-14 09:35:38'),
(32, 'Oggetto 1 di luigi', 'Oggetto con immagine caricata via API', 1, '2025-05-17', '/uploads/items/item_32_6a05976ace6eb2.46248994.jpg', 3, 11, '2026-05-14 09:35:38'),
(33, 'Oggetto 2 di luigi', 'Oggetto con immagine caricata via API', 5, '2025-03-30', '/uploads/items/item_33_6a05976b1db1c4.41018644.jpg', 3, 11, '2026-05-14 09:35:38'),
(34, 'Oggetto 3 di luigi', 'Oggetto con immagine caricata via API', 2, '2024-07-25', '/uploads/items/item_34_6a05976b625619.30553975.jpg', 3, 11, '2026-05-14 09:35:39'),
(35, 'Oggetto 4 di luigi', 'Oggetto con immagine caricata via API', 3, '2025-01-22', '/uploads/items/item_35_6a05976b9eda66.49748180.jpg', 3, 11, '2026-05-14 09:35:39'),
(36, 'Oggetto 1 di anna', 'Oggetto con immagine caricata via API', 4, '2024-09-08', '/uploads/items/item_36_6a05976c211085.43183206.jpg', 4, 12, '2026-05-14 09:35:39'),
(37, 'Oggetto 2 di anna', 'Oggetto con immagine caricata via API', 2, '2024-08-20', '/uploads/items/item_37_6a05976c6300a1.80864238.jpg', 4, 12, '2026-05-14 09:35:40'),
(38, 'Oggetto 3 di anna', 'Oggetto con immagine caricata via API', 2, '2025-06-20', '/uploads/items/item_38_6a05976c9f12b7.45359610.jpg', 4, 12, '2026-05-14 09:35:40'),
(39, 'Oggetto 4 di anna', 'Oggetto con immagine caricata via API', 5, '2025-10-28', '/uploads/items/item_39_6a05976cdb42b2.60505643.jpg', 4, 12, '2026-05-14 09:35:40'),
(40, 'Oggetto 1 di sofia', 'Oggetto con immagine caricata via API', 4, '2024-08-20', '/uploads/items/item_40_6a0599c7cdae20.65286648.jpg', 5, 13, '2026-05-14 09:45:43'),
(41, 'Oggetto 2 di sofia', 'Oggetto con immagine caricata via API', 2, '2025-07-24', '/uploads/items/item_41_6a0599c81f1e83.12827856.jpg', 5, 13, '2026-05-14 09:45:43'),
(42, 'Oggetto 3 di sofia', 'Oggetto con immagine caricata via API', 4, '2025-11-24', '/uploads/items/item_42_6a0599c85596c5.02484045.jpg', 5, 13, '2026-05-14 09:45:44'),
(43, 'Oggetto 4 di sofia', 'Oggetto con immagine caricata via API', 2, '2025-07-13', '/uploads/items/item_43_6a0599c88fe9c2.88370284.jpg', 5, 13, '2026-05-14 09:45:44');


INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `api_token`, `created_at`) VALUES
(1, 'giro', 'giro@giro.it', '$2y$10$3sSpGrae5Tyl9h9IbZ9wfOjyUH5Zt6OyP/sZSyPG5i2HhmgEssCzS', 'ac000dde13c665d704e2a6a53172628b8af124ad9872bbce7e5132b855665ac9', '2026-05-12 09:53:10'),
(2, 'mario', 'mario@test.it', '$2y$10$6iw7HaY5dIjcJjicS7YikeyUHwiDAO9hW8AL6HHZocbyDlkoO1fwG', '9a8926f6d5e74289b779ed642e9cc4ce1ea643c60fd26f61df15f4ca39d5f4a6', '2026-05-14 08:48:50'),
(3, 'luigi', 'luigi@test.it', '$2y$10$leXk.t19pbAiibf6lS5LIOMujhpTfK6ayrcGguekt1X1.zUrtToIq', '58ea35109f8db06b63c2bc2af7eb2d609078b2eff6839d9060a065cd8c513420', '2026-05-14 08:48:51'),
(4, 'anna', 'anna@test.it', '$2y$10$K.tzWsgH74lZOVKHbQCbn.zDGfAMCDJXi1Az4mpxnhBiDTk8nGWfi', 'fb887b98e5e5525d1cb620d98dbeea080a9cc4facf728c2e608b6b2f1b7415fb', '2026-05-14 08:48:51'),
(5, 'sofia', 'sofia@test.it', '$2y$10$bekJluKe8tV3Qt2OKX0rteMb9iy4I5F0rie9Ym/KGf8MEUX4wsnfC', 'cb7725ab751fd88c0d45ae8a34e05a8860c284e3eb78c8c6859f2133660e6bad', '2026-05-14 08:48:51');
