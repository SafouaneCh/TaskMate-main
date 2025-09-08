# TaskMate AI - Application Mobile de Gestion de Tâches Intelligente

## 📱 Description du Projet

TaskMate AI est une application mobile Flutter qui utilise l'intelligence artificielle pour transformer automatiquement des descriptions en langage naturel en tâches structurées et planifiées. L'application combine un backend personnalisé avec des services cloud pour offrir une expérience utilisateur moderne et intuitive.

## 🏗️ Architecture du Projet

```
TaskMate AI
├── Frontend (Flutter)
│   ├── UI Layer (Screens, Widgets)
│   ├── State Management (Cubits)
│   └── Business Logic (Services, Repositories)
├── Backend (API REST)
│   ├── Authentication
│   ├── Task Management
│   └── AI Services
└── External Services
    ├── Supabase (Database)
    └── OneSignal (Notifications)
```

## 🚀 Installation et Configuration

### Prérequis
- Flutter SDK 3.3.0+
- Dart SDK
- Android Studio / VS Code
- Backend API en cours d'exécution

### Configuration
1. Cloner le repository
```bash
git clone <https://github.com/SafouaneCh/TaskMate-main.git>
cd TaskMate-main
```

2. Installer les dépendances
```bash
flutter pub get
```

3. Configurer les variables d'environnement
```bash
# Créer un fichier .env à la racine
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
ONESIGNAL_APP_ID=your_onesignal_app_id
```

4. Configurer le backend
```bash
# Modifier lib/core/constants/constants.dart
static String backendUri = "http://your-backend-url:port";
```

5. Lancer l'application
```bash
flutter run
```

## 📚 Documentation des APIs

### [API Backend](./docs/backend-api.md)
Documentation complète de l'API REST du backend personnalisé.

### [API Services](./docs/services-api.md)
Documentation des services internes et des patterns utilisés.

### [API Repository](./docs/repository-api.md)
Documentation des repositories et de l'accès aux données.

### [API Cubit](./docs/cubit-api.md)
Documentation de la gestion d'état avec Flutter Bloc.

## 🔧 Technologies Utilisées

- **Frontend**: Flutter, Dart
- **State Management**: Flutter Bloc (Cubit)
- **Backend**: API REST personnalisée
- **Database**: Supabase (PostgreSQL)
- **Notifications**: OneSignal
- **AI Integration**: Services IA personnalisés
- **Storage**: SQLite (local), Supabase (cloud)

## 📁 Structure du Code

```
lib/
├── core/           # Services et constantes partagés
├── cubit/          # Gestion d'état (Bloc)
├── models/         # Modèles de données
├── repository/     # Accès aux données
├── screens/        # Écrans de l'application
├── services/       # Services métier
└── widgets/        # Composants réutilisables
```

## 🎯 Fonctionnalités Principales

- ✅ Authentification utilisateur
- ✅ Création de tâches manuelle et IA
- ✅ Parsing intelligent du langage naturel
- ✅ Gestion des contacts
- ✅ Planification temporelle
- ✅ Notifications push
- ✅ Synchronisation cloud
- ✅ Interface moderne et intuitive

```

## 📱 Captures d'écran

[À ajouter : captures d'écran de l'application]

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request


## 👥 Équipe

- **Développeurs Principal**: Safouane Charki -Ayman Raoui
- **Encadrant**: Zakaria Bentahar
- **Organisation**: Synexon Technology

---

**TaskMate AI** - Révolutionner la gestion des tâches avec l'intelligence artificielle 🚀
