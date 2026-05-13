# Collectiv - Documentazione Client Flutter

**Collectiv** è un'applicazione Web sviluppata in Flutter per la gestione di collezioni personali. Offre un'interfaccia moderna in stile "Glassmorphism" per tracciare oggetti, categorie e consultare statistiche dettagliate tramite un backend RESTful in PHP.

---

## Funzionalità Principal

- **Autenticazione** — Accesso e registrazione basati su API Token (Bearer) con validazione dei form.
- **Dashboard** — Panoramica immediata con statistiche globali, ultimi oggetti aggiunti e "Highlights" della collezione.
- **Categorie** — Gestione completa (CRUD) di categorie personalizzate. Filtro rapido degli oggetti per categoria.
- **Inventario** — Gestione totale degli oggetti: nome, descrizione, valutazione (1–5★), data di acquisizione, associazione categoria e caricamento immagini.
- **Analytics (Nerd Stats)** — Collector Score, grafico della distribuzione dei voti, timeline delle acquisizioni con slider temporale, tabella per categoria e record della collezione (oggetto migliore, più recente, più vecchio, ecc.).
- **Impostazioni** — Modifica profilo (username, email, password) e cancellazione definitiva dell'account.
- **Layout Responsive** — Sidebar adattiva per desktop e navigazione inferiore (Bottom Nav) per dispositivi mobile.

---

## Tech Stack

| Livello          | Tecnologia                           |
|------------------|--------------------------------------|
| **Framework**    | Flutter 3.x (Web)                    |
| **Stato**        | Provider (`ChangeNotifier`)          |
| **Routing**      | GoRouter                             |
| **HTTP**         | Pacchetto `http`                     |
| **Grafici**      | `fl_chart`                           |
| **Tipografia**   | Google Fonts (Plus Jakarta Sans, Inter) |
| **Persistenza**  | SharedPreferences (Salvataggio Token) |

---

## Installazione e Avvio

### 1. Installare le dipendenze
```bash
flutter pub get
```

### 2. Avviare l'app in sviluppo
Per evitare problemi di CORS durante lo sviluppo locale con il backend PHP, utilizzare il seguente comando:
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### 3. Build per produzione
```bash
flutter build web
```
I file generati si troveranno in `build/web/` e potranno essere ospitati su qualsiasi server statico o nella cartella `htdocs` di XAMPP.

---

## Struttura del Progetto

```
lib/
├── main.dart                  # Punto di ingresso, configurazione tema e provider
├── models/                    # Modelli dati per la serializzazione API
│   ├── category.dart          # Modello Categoria
│   ├── item.dart              # Modello Oggetto (Item)
│   ├── stats.dart             # Modelli per statistiche, record e timeline
│   └── user.dart              # Modello Utente
├── providers/                 # Logica di business e gestione dello stato
│   ├── auth_provider.dart     # Stato autenticazione e profilo
│   ├── category_provider.dart # Gestione CRUD categorie
│   ├── item_provider.dart     # Gestione CRUD oggetti, ricerca e paginazione
│   └── stats_provider.dart    # Recupero dati aggregati e statistiche
├── routing/
│   └── app_router.dart        # Configurazione GoRouter con guardie di autenticazione
├── screens/                   # Schermate principali dell'app
│   ├── home_screen.dart       # Dashboard e Highlights
│   ├── categories_screen.dart # Lista categorie e dialoghi CRUD
│   ├── items_screen.dart      # Griglia oggetti, filtri e dialoghi CRUD
│   ├── stats_screen.dart      # Analytics e grafici
│   ├── settings_screen.dart   # Modifica profilo e cancellazione account
│   ├── login_screen.dart      # Form di login
│   └── register_screen.dart   # Form di registrazione
├── services/
│   └── api_service.dart       # Client HTTP standardizzato
└── widgets/                   # Componenti UI riutilizzabili
    ├── app_layout.dart        # Shell responsive (Sidebar + Bottom Nav)
    ├── glass_panel.dart       # Container in stile vetro
    ├── animated_glass_card.dart # Card animata con effetto hover
    └── star_rating.dart       # Input interattivo per la valutazione
```

---

## Sistema di Design (Glassmorphism)

L'app adotta un tema scuro basato su Material 3 con un'estetica **dark-slate glassmorphism**:

- **Colori** — Palette basata su toni Zinc (`#09090B` background) con accenti Blue Primary (`#3B82F6`), Violet e Teal.
- **Effetti Visivi** — Pannelli semi-trasparenti con sfocatura dello sfondo (backdrop blur), bordi sfumati e ombreggiature profonde.
- **Animazioni** — Hover-scale e glow esterno tramite il widget `AnimatedGlassCard` per un feedback utente premium.

---

## Navigazione (Routing)

| Percorso       | Schermata         | Autenticazione |
|----------------|-------------------|:--------------:|
| `/login`       | LoginScreen       | No             |
| `/register`    | RegisterScreen    | No             |
| `/`            | HomeScreen        | **Sì**         |
| `/categories`  | CategoriesScreen  | **Sì**         |
| `/items`       | ItemsScreen       | **Sì**         |
| `/stats`       | StatsScreen       | **Sì**         |
| `/settings`    | SettingsScreen    | **Sì**         |

Gli utenti non autenticati vengono reindirizzati automaticamente al `/login`. Gli utenti già autenticati che tentano di accedere a login o register vengono reindirizzati alla home `/`.
