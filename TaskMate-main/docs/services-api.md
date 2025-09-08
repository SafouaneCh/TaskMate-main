# API Services - TaskMate AI

## 🔧 Vue d'ensemble

Les services de TaskMate AI sont des composants spécialisés qui gèrent la logique métier, l'intégration des services externes et la synchronisation des données. Ils suivent le pattern Service et sont organisés en couches logiques.

## 📁 Structure des Services

```
services/
├── ai_parsing_service.dart      # Service de parsing IA
├── sync_service.dart            # Service de synchronisation
└── network_service.dart         # Service de connectivité

core/services/
├── reminder_service.dart        # Service de rappels
├── onesignal_service.dart      # Service de notifications
└── sp_service.dart             # Service de stockage local
```

## 🤖 AIParsingService

**Fichier** : `lib/services/ai_parsing_service.dart`

**Responsabilité** : Gestion des appels vers les services d'intelligence artificielle pour le parsing et la création de tâches.

### Méthodes publiques

#### `parseTask(String naturalLanguageInput, String token)`
**Description** : Parse une description en langage naturel en données structurées.

**Paramètres :**
- `naturalLanguageInput` : Description de la tâche en langage naturel
- `token` : Token d'authentification de l'utilisateur

**Retour :** `Future<Map<String, dynamic>>` - Données parsées de la tâche

**Utilisation :**
```dart
final parsedData = await AIParsingService.parseTask(
  "Rappelle-moi d'appeler Amine demain à 14h",
  userToken
);
```

#### `createAITask(String naturalLanguageInput, String token)`
**Description** : Crée une tâche directement via l'IA.

**Paramètres :**
- `naturalLanguageInput` : Description de la tâche en langage naturel
- `token` : Token d'authentification de l'utilisateur

**Retour :** `Future<Map<String, dynamic>>` - Tâche créée avec toutes ses métadonnées

**Utilisation :**
```dart
final result = await AIParsingService.createAITask(
  "Rappelle-moi d'appeler Amine demain à 14h",
  userToken
);
```

#### `testConnection()`
**Description** : Teste la connectivité avec le backend.

**Retour :** `Future<bool>` - True si la connexion est établie

#### `getConnectionStatus()`
**Description** : Retourne un message de statut de connexion.

**Retour :** `Future<String>` - Message de statut de la connexion

### Gestion des erreurs
- Timeout de 30 secondes pour les appels IA
- Gestion des erreurs de connexion HTTP
- Messages d'erreur explicites pour le débogage

---

## 🔄 SyncService

**Fichier** : `lib/services/sync_service.dart`

**Responsabilité** : Synchronisation bidirectionnelle entre le stockage local et Supabase, avec gestion des opérations hors ligne.

**Pattern** : Singleton

### Méthodes publiques

#### `initialize()`
**Description** : Initialise le service de synchronisation.

**Retour :** `Future<void>`

#### `_checkConnectivity()`
**Description** : Vérifie la connectivité avec Supabase.

**Retour :** `Future<bool>` - True si connecté

### Fonctionnalités
- **Synchronisation périodique** : Toutes les 5 secondes quand en ligne
- **File d'attente** : Gestion des opérations en attente de synchronisation
- **Opérations supportées** : create_task, update_task, delete_task
- **Gestion des erreurs** : Réajout des opérations échouées dans la file

### Utilisation
```dart
// Initialisation
await SyncService().initialize();

// Le service fonctionne automatiquement en arrière-plan
```

---

## 🌐 NetworkService

**Fichier** : `lib/services/network_service.dart`

**Responsabilité** : Surveillance de la connectivité réseau et notification des changements d'état.

**Pattern** : Singleton avec Observer

### Méthodes publiques

#### `initialize()`
**Description** : Initialise la surveillance de la connectivité.

**Retour :** `Future<void>`

#### `addListener(Function(bool) listener)`
**Description** : Ajoute un écouteur pour les changements de connectivité.

**Paramètres :**
- `listener` : Fonction appelée lors des changements de connectivité

#### `removeListener(Function(bool) listener)`
**Description** : Supprime un écouteur de connectivité.

#### `isConnected`
**Getter** : Retourne l'état actuel de la connectivité.

#### `testInternetConnection()`
**Description** : Teste la connectivité Internet en résolvant google.com.

**Retour :** `Future<bool>` - True si Internet est accessible

### Fonctionnalités
- **Surveillance en temps réel** : Détection automatique des changements de connectivité
- **Pattern Observer** : Notification des composants intéressés
- **Test de connectivité** : Vérification de l'accessibilité Internet

### Utilisation
```dart
// Initialisation
await NetworkService().initialize();

// Ajout d'un écouteur
NetworkService().addListener((isConnected) {
  if (isConnected) {
    print('Connecté à Internet');
  } else {
    print('Déconnecté d\'Internet');
  }
});

// Vérification de l'état
if (NetworkService().isConnected) {
  // Effectuer des opérations réseau
}
```

---

## 🔔 OneSignalService

**Fichier** : `lib/core/services/onesignal_service.dart`

**Responsabilité** : Gestion des notifications push via OneSignal.

### Méthodes publiques

#### `initialize()`
**Description** : Initialise le service OneSignal.

**Retour :** `Future<void>`

#### `setExternalUserId(String userId)`
**Description** : Associe l'ID utilisateur OneSignal à l'utilisateur de l'application.

**Paramètres :**
- `userId` : ID de l'utilisateur dans l'application

### Fonctionnalités
- **Gestion des permissions** : Demande automatique des permissions de notification
- **Handlers d'événements** : Gestion des clics et affichage des notifications
- **Association utilisateur** : Liaison entre OneSignal et l'utilisateur de l'app

---

## 💾 SpService (SharedPreferences Service)

**Fichier** : `lib/core/services/sp_service.dart`

**Responsabilité** : Gestion du stockage local des préférences utilisateur.

### Méthodes publiques

#### Gestion des tokens
- `setToken(String token)` : Stocke le token d'authentification
- `getToken()` : Récupère le token stocké
- `removeToken()` : Supprime le token stocké

#### Gestion des notifications
- `setNotificationSettings(...)` : Configure les paramètres de notification
- `getNotificationSettings()` : Récupère la configuration des notifications

#### Gestion de la sécurité
- `setSecuritySettings(...)` : Configure les paramètres de sécurité
- `getSecuritySettings()` : Récupère la configuration de sécurité

### Utilisation
```dart
final spService = SpService();

// Stockage d'un token
await spService.setToken('user_token_123');

// Récupération d'un token
final token = await spService.getToken();

// Configuration des notifications
await spService.setNotificationSettings(
  pushNotifications: true,
  emailNotifications: false,
  taskReminders: true,
  dailyDigest: false,
);
```

---

## 🎯 ReminderService

**Fichier** : `lib/core/services/reminder_service.dart`

**Responsabilité** : Gestion des rappels et notifications locales.

### Fonctionnalités
- **Planification de rappels** : Création de rappels programmés
- **Types de rappels** : Différents intervalles (1 heure, 30 minutes, etc.)
- **Gestion des permissions** : Vérification des permissions de notification
- **Annulation de rappels** : Suppression des rappels programmés

---

## 🔗 Intégration des Services

### Flux de synchronisation
```
1. NetworkService détecte la connectivité
2. SyncService synchronise avec Supabase
3. OneSignalService envoie les notifications
4. SpService stocke les préférences locales
```

### Gestion des erreurs
- **Timeout** : Gestion des délais d'attente
- **Retry** : Tentatives de reconnexion automatiques
- **Fallback** : Utilisation des données locales en cas d'échec réseau

### Performance
- **Singleton** : Une seule instance par service
- **Lazy loading** : Initialisation à la demande
- **Cache** : Mise en cache des données fréquemment utilisées

---

## 🧪 Tests des Services

### Tests unitaires
```bash
# Test d'un service spécifique
flutter test test/services/ai_parsing_service_test.dart

# Test de tous les services
flutter test test/services/
```

### Mocking
```dart
// Exemple de mock pour AIParsingService
class MockAIParsingService extends Mock implements AIParsingService {
  @override
  Future<Map<String, dynamic>> createAITask(
    String input, String token) async {
    return {
      'task': {
        'id': 'mock_id',
        'name': 'Mock Task',
        'description': 'Mock Description',
        // ... autres propriétés
      }
    };
  }
}
```

---

## 📚 Bonnes Pratiques

### 1. **Séparation des responsabilités**
- Chaque service a une responsabilité unique et bien définie
- Pas de logique métier dans les services de données

### 2. **Gestion des erreurs**
- Capture et gestion appropriée de toutes les exceptions
- Messages d'erreur explicites pour le débogage

### 3. **Performance**
- Utilisation du pattern Singleton pour les services coûteux
- Mise en cache des données fréquemment utilisées

### 4. **Testabilité**
- Services facilement mockables pour les tests
- Dépendances injectées plutôt que créées en interne

---

**Note** : Ces services sont conçus pour être extensibles et maintenables. Consultez le code source pour les détails d'implémentation complets.
