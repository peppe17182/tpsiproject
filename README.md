# Collector Tracker - Documentazione Web Service

## 1. Descrizione della realta' di riferimento

**Collector Tracker** e' un sistema per collezionisti che permette di catalogare oggetti di qualsiasi tipo (monete, fumetti, videogiochi, orologi), organizzarli in categorie, assegnare voti da 1 a 10 e consultare classifiche e statistiche. Il web service espone le risorse in formato JSON tramite un'API RESTful, progettata per essere consumata da un'applicazione mobile Flutter.

---

## 2. URL del Web Service

```
http://localhost/web/collector_tracker/
```

---

## 3. Script PHP che gestiscono le richieste

L'unico script invocato direttamente dal web server e' **`index.php`**, posizionato nella directory base. Viene eseguito per **tutte** le richieste in arrivo, grazie alla riscrittura degli URL operata dal file `.htaccess`. Lo script `index.php` analizza il percorso richiesto e instrada la logica verso i file nella directory `/specific`.

---

## 4. Risorse gestite e URI

### 4.1 Utenti (`users`)

Rappresenta i collezionisti registrati nel sistema.

| Proprieta'    | Tipo      | Descrizione                    |
|---------------|-----------|--------------------------------|
| id            | INT       | Identificativo univoco (PK)   |
| username      | VARCHAR   | Nome utente univoco            |
| email         | VARCHAR   | Indirizzo email univoco        |
| created_at    | TIMESTAMP | Data di registrazione          |

**Operazioni CRUD consentite:** solo Read (GET).

| Metodo | URI            | Descrizione                                       | Status possibili |
|--------|----------------|---------------------------------------------------|------------------|
| GET    | `/users`       | Array JSON con dati parziali (id, username)       | 200              |
| GET    | `/users/{id}`  | Oggetto JSON con tutti i dati dell'utente         | 200, 404         |

---

### 4.2 Categorie (`categories`)

Rappresenta le tipologie di oggetti da collezione (es. Monete, Fumetti).

| Proprieta'    | Tipo      | Descrizione                    |
|---------------|-----------|--------------------------------|
| id            | INT       | Identificativo univoco (PK)   |
| name          | VARCHAR   | Nome della categoria (univoco) |
| description   | TEXT      | Descrizione opzionale          |
| created_at    | TIMESTAMP | Data di creazione              |

**Operazioni CRUD consentite:** Read (GET), Create (POST), Delete (DELETE).

| Metodo | URI                 | Descrizione                                 | Status possibili   |
|--------|---------------------|---------------------------------------------|---------------------|
| GET    | `/categories`       | Array JSON con dati parziali (id, name)     | 200                 |
| GET    | `/categories/{id}`  | Oggetto JSON completo della categoria       | 200, 404            |
| POST   | `/categories`       | Crea nuova categoria. Body: `{name, description?}` | 201, 400      |
| DELETE | `/categories/{id}`  | Elimina la categoria specificata            | 200, 404            |

---

### 4.3 Oggetti (`items`)

Entita' principale: un oggetto da collezione, associato a un utente e a una categoria.

| Proprieta'        | Tipo    | Descrizione                             |
|-------------------|---------|-----------------------------------------|
| id                | INT     | Identificativo univoco (PK)            |
| name              | VARCHAR | Nome dell'oggetto                       |
| description       | TEXT    | Descrizione dettagliata                 |
| rating            | INT     | Voto da 1 a 10                          |
| acquisition_date  | DATE    | Data di acquisizione                    |
| user_id           | INT     | FK verso users.id                       |
| category_id       | INT     | FK verso categories.id                  |
| created_at        | TIMESTAMP | Data di inserimento nel sistema       |

**Operazioni CRUD consentite:** Read, Create, Update (PUT + PATCH), Delete.

| Metodo | URI                      | Descrizione                                             | Status possibili |
|--------|--------------------------|---------------------------------------------------------|------------------|
| GET    | `/items`                 | Array JSON parziale (id, name, rating). Query string opzionali: `?category_id=X`, `?user_id=X` | 200 |
| GET    | `/items/{id}`            | Oggetto JSON completo                                   | 200, 404         |
| GET    | `/items/category/{id}`   | URI composta: oggetti filtrati per categoria             | 200, 400         |
| GET    | `/items/user/{id}`       | URI composta: oggetti filtrati per utente                | 200, 400         |
| POST   | `/items`                 | Crea oggetto. Body: `{name, user_id, category_id, description?, rating?, acquisition_date?}` | 201, 400 |
| PUT    | `/items/{id}`            | Sostituzione completa. Body: tutti i campi obbligatori  | 200, 400, 404    |
| PATCH  | `/items/{id}`            | Aggiornamento parziale. Body: solo i campi da modificare | 200, 400, 404   |
| DELETE | `/items/{id}`            | Elimina l'oggetto specificato                           | 200, 404         |

---

### 4.4 Statistiche (`stats`)

Risorsa virtuale che aggrega dati per i grafici dell'applicazione Flutter.

| Metodo | URI                  | Descrizione                                       | Status possibili |
|--------|----------------------|---------------------------------------------------|------------------|
| GET    | `/stats/rankings`    | Top 10 oggetti per rating (dati per Bar Chart)    | 200              |
| GET    | `/stats/categories`  | Conteggio oggetti per categoria (dati per Pie Chart) | 200           |

**Formato risposta `/stats/rankings`:**
```json
[{"id": 3, "name": "Spider-Man #1", "rating": 10, "category": "Fumetti"}, ...]
```

**Formato risposta `/stats/categories`:**
```json
[{"label": "Monete", "value": 3}, {"label": "Fumetti", "value": 2}, ...]
```

---

## 5. Associazioni tra le risorse (Schema E/R)

```
+----------+        1:N        +----------+
|  USERS   |<-----------------| ITEMS    |
+----------+                   +----------+
| PK: id   |                   | PK: id   |
| username |                   | name     |
| email    |                   | rating   |
+----------+                   | FK: user_id
                               | FK: category_id
+------------+      1:N       +----------+
| CATEGORIES |<---------------|          |
+------------+                 +----------+
| PK: id     |
| name       |
+------------+
```

**Relazioni:**
- **Users -> Items**: un utente possiede zero o piu' oggetti (1:N).
- **Categories -> Items**: una categoria contiene zero o piu' oggetti (1:N).
- Entrambe le FK hanno `ON DELETE CASCADE`.

---

## 6. Schema logico del database

```sql
users(id PK, username UNIQUE, email UNIQUE, created_at)
categories(id PK, name UNIQUE, description, created_at)
items(id PK, name, description, rating, acquisition_date, user_id FK->users, category_id FK->categories, created_at)
```

---

## 7. Elementi di innovazione

1. **Metodo PATCH**: aggiornamento parziale degli oggetti con costruzione dinamica sicura della query SQL.
2. **Configurazione INI**: credenziali e parametri in `config.ini` (formato INI) nella directory base, letti dinamicamente da `config.php`.
3. **Autorizzazione API Key**: ogni richiesta deve includere l'header `X-API-Key` o il parametro `?api_key=` con il token configurato.
4. **URI composte**: `/items/category/{id}` e `/items/user/{id}` per navigazione avanzata tra risorse.

---

## 8. Struttura delle directory

```
collector_tracker/
├── .htaccess                  # Rewrite rules e sicurezza
├── config.ini                 # Dati di configurazione (formato INI)
├── database.sql               # Script DDL + dati di test
├── index.php                  # Router (unico script eseguito dal web server)
├── README.md                  # Questa documentazione
├── general/
│   ├── config.php             # Costanti di configurazione (legge da config.ini)
│   ├── db_helper.php          # Connessione PDO al database
│   └── response_helper.php    # Funzioni per risposte JSON e autorizzazione
└── specific/
    ├── UserManager.php        # Logica risorsa Utenti
    ├── CategoryManager.php    # Logica risorsa Categorie
    ├── ItemManager.php        # Logica risorsa Oggetti
    └── StatsManager.php       # Logica risorsa Statistiche
```
