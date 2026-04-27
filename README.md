# Collector Tracker - Documentazione Web Service

## 1. Descrizione della realta' di riferimento

**Collector Tracker** e' un sistema per collezionisti che permette di catalogare oggetti di qualsiasi tipo, organizzarli in categorie, assegnare voti e consultare classifiche e statistiche. Il web service espone le risorse in formato JSON tramite un'API RESTful. Ogni utente gestisce in modo privato e isolato le proprie categorie e i propri oggetti.

---

## 2. URL del Web Service

```
http://localhost/web/
```

---

## 3. Script PHP che gestiscono le richieste

L'unico script invocato direttamente dal web server e' **`index.php`**, posizionato nella directory base. Viene eseguito per **tutte** le richieste in arrivo, grazie alla riscrittura degli URL operata dal file `.htaccess`. Lo script `index.php` analizza il percorso richiesto e instrada la logica verso i file specifici nella directory `/api`.

---

## 4. Risorse gestite e URI

Le API richiedono (tranne Auth e GET users) un **Bearer Token** nell'header `Authorization`, ottenuto tramite Login.

### 4.1 Autenticazione (`auth`)
Gestisce l'accesso al sistema.
| Metodo | URI            | Descrizione                                       |
|--------|----------------|---------------------------------------------------|
| POST   | `/auth/register`| Registra un nuovo utente                         |
| POST   | `/auth/login`  | Restituisce il token di accesso (Bearer)          |
| GET    | `/auth/me`     | Ritorna i dati dell'utente loggato                |

### 4.2 Utenti (`users`)
Rappresenta i collezionisti registrati.
**Operazioni CRUD:** Read (parziale di tutti/completa per id), Update (solo per sé), Delete (solo per sé).
| Metodo | URI            | Descrizione                                       |
|--------|----------------|---------------------------------------------------|
| GET    | `/users`       | Array JSON con dati parziali (id, username)       |
| GET    | `/users/{id}`  | Oggetto JSON con i dati di un utente specifico    |
| PUT    | `/users/{id}`  | Aggiorna il proprio profilo                       |
| DELETE | `/users/{id}`  | Elimina definitivamente il proprio account        |

### 4.3 Categorie (`categories`)
Rappresenta le tipologie di oggetti. **Sono strettamente private e legate all'utente loggato.**
**Operazioni CRUD:** Create, Read, Update, Delete.
| Metodo | URI                 | Descrizione                                 |
|--------|---------------------|---------------------------------------------|
| GET    | `/categories`       | Array JSON con dati parziali delle proprie categorie |
| GET    | `/categories/{id}`  | Oggetto JSON completo della propria categoria |
| POST   | `/categories`       | Crea nuova categoria personale              |
| PUT    | `/categories/{id}`  | Modifica la propria categoria               |
| DELETE | `/categories/{id}`  | Elimina la categoria e gli item associati   |

### 4.4 Oggetti (`items`)
L'entità principale del sistema. Associato all'utente loggato e a una delle sue categorie.
**Operazioni CRUD:** Create, Read (paginata), Update, Delete.
| Metodo | URI                      | Descrizione                                             |
|--------|--------------------------|---------------------------------------------------------|
| GET    | `/items`                 | Elenco dei propri item. Supporta paginazione (`?page=1&limit=20`) e ricerca (`?search=x`) |
| GET    | `/items/{id}`            | Oggetto JSON completo del singolo item                  |
| POST   | `/items`                 | Crea oggetto nella propria collezione                   |
| PUT    | `/items/{id}`            | Aggiornamento completo del proprio oggetto              |
| DELETE | `/items/{id}`            | Elimina l'oggetto dalla propria collezione              |

### 4.5 Statistiche (`stats`)
Risorsa virtuale che aggrega dati.
| Metodo | URI                  | Descrizione                                       |
|--------|----------------------|---------------------------------------------------|
| GET    | `/stats`             | Ritorna statistiche e raggruppamenti del DB       |

### 4.6 Caricamento File (`upload`)
Le immagini sono strettamente legate all'oggetto.
| Metodo | URI                  | Descrizione                                       |
|--------|----------------------|---------------------------------------------------|
| POST   | `/upload/{item_id}`  | Carica un'immagine e aggiorna il DB dell'oggetto  |
| DELETE | `/upload/{item_id}`  | Elimina l'immagine dal server e dal DB            |

---

## 5. Associazioni tra le risorse (Schema E/R)

```
       +------------+
       |   USERS    |
       +------------+
       | PK: id     |
       | username   |
       | email      |
       +------------+
          |      |
      1:N |      | 1:N
          |      |
          v      v
+------------+  +----------+
| CATEGORIES |  |  ITEMS   |
+------------+  +----------+
| PK: id     |  | PK: id   |
| name       |  | name     |
| FK: user_id|  | rating   |
+------------+  | FK: user_id
       |        | FK: cat_id
       +------->|
          1:N   +----------+
```

**Relazioni (tutte ON DELETE CASCADE):**
- **Users -> Categories**: un utente crea le sue categorie private (1:N).
- **Users -> Items**: un utente possiede i suoi oggetti (1:N).
- **Categories -> Items**: una categoria privata contiene oggetti di quell'utente (1:N).

---

## 6. Schema logico del database

```sql
users (
  id PK, username UNIQUE, email UNIQUE, password_hash, api_token UNIQUE, created_at
)
categories (
  id PK, name, description, user_id FK->users, created_at
  -- UNIQUE (name, user_id)
)
items (
  id PK, name, description, rating, acquisition_date, image_url, 
  user_id FK->users, category_id FK->categories, created_at
)
```

---

## 7. Elementi di innovazione

1. **Autenticazione a Token Personale (Bearer)**: Sistema di login e registrazione protetto da hashing (`bcrypt`), isolamento completo dei dati per utente tramite l'header `Authorization`.
2. **Architettura a Compartimenti Stagni**: Le categorie e gli item sono rigidamente vincolati all'ID dell'utente loggato, garantendo il pieno isolamento e rispetto della privacy.
3. **Paginazione Avanzata**: L'endpoint `/items` implementa LIMIT e OFFSET dinamici, restituendo meta-dati per il calcolo delle pagine.
4. **Configurazione INI**: Parametri isolati nel file `config.ini` nella root, come da requisiti di design avanzato.
5. **Gestione File Upload**: Endpoint dedicato al salvataggio locale dei file e restituzione del path relativo.

---

## 8. Struttura delle directory

```
/
├── .htaccess                  # Rewrite rules
├── config.ini                 # Dati di configurazione (escluso da git)
├── database.sql               # Script DDL per MySQL
├── index.php                  # Router centrale (Front Controller)
├── README.md                  # Documentazione tecnica
├── api/                       # Controller risorse
│   ├── Auth.php
│   ├── Category.php
│   ├── Item.php
│   ├── Stats.php
│   ├── Upload.php
│   └── User.php
├── config/
│   └── database.php           # Gestione Singleton per connessione PDO
└── core/
    ├── Auth.php               # Logica di validazione del token
    └── Response.php           # Helper per risposte JSON
```
