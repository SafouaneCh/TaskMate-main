# API Repository - TaskMate AI

## 🗄️ Vue d'ensemble

Les repositories de TaskMate AI implémentent le pattern Repository pour abstraire l'accès aux données. Ils gèrent la communication avec les sources de données externes (API REST, Supabase) et fournissent une interface unifiée pour la couche métier.

## 📁 Structure des Repositories

```
repository/
├── auth_remote_repository.dart    # Gestion de l'authentification
└── task_remote_repository.dart    # Gestion des tâches
```

## 🔐 AuthRemoteRepository

**Fichier** : `lib/repository/auth_remote_repository.dart`

**Responsabilité** : Gestion de l'authentification utilisateur via l'API REST backend.

**Pattern** : Repository

### Dépendances
- `http` package pour les appels HTTP
- `SpService` pour le stockage local des tokens
- `UserModel` pour la sérialisation des données

### Méthodes publiques

#### `signUp({required String name, required String email, required String password, required String phone})`
**Description** : Inscription d'un nouvel utilisateur.

**Paramètres :**
- `name` : Nom complet de l'utilisateur
- `email` : Adresse email unique
- `password` : Mot de passe sécurisé
- `phone` : Numéro de téléphone

**Retour :** `Future<UserModel>` - Modèle utilisateur créé

**Endpoint :** `POST /auth/signup`

**Gestion des erreurs :**
- Validation des codes de statut HTTP
- Parsing des messages d'erreur du backend
- Propagation des erreurs vers la couche métier

**Utilisation :**
```dart
final authRepo = AuthRemoteRepository();
try {
  final user = await authRepo.signUp(
    name: "John Doe",
    email: "john@example.com",
    password: "securePassword123",
    phone: "+1234567890"
  );
  // Utilisateur créé avec succès
} catch (e) {
  // Gestion de l'erreur
  print('Erreur d\'inscription: $e');
}
```

#### `login({required String name, required String email, required String password})`
**Description** : Connexion d'un utilisateur existant.

**Paramètres :**
- `name` : Nom d'utilisateur
- `email` : Adresse email
- `password` : Mot de passe

**Retour :** `Future<UserModel>` - Modèle utilisateur connecté

**Endpoint :** `POST /auth/login`

**Fonctionnalités :**
- Stockage automatique du token dans SpService
- Validation des identifiants
- Gestion des erreurs d'authentification

**Utilisation :**
```dart
final authRepo = AuthRemoteRepository();
try {
  final user = await authRepo.login(
    name: "John Doe",
    email: "john@example.com",
    password: "securePassword123"
  );
  // Connexion réussie, token stocké automatiquement
} catch (e) {
  // Gestion de l'erreur
  print('Erreur de connexion: $e');
}
```

#### `getUserData()`
**Description** : Récupération des données utilisateur via validation de token.

**Retour :** `Future<UserModel?>` - Modèle utilisateur ou null si non connecté

**Endpoint :** `POST /auth/tokenIsValid`

**Fonctionnalités :**
- Récupération automatique du token depuis SpService
- Validation du token avec le backend
- Retour des données utilisateur complètes

**Utilisation :**
```dart
final authRepo = AuthRemoteRepository();
try {
  final user = await authRepo.getUserData();
  if (user != null) {
    // Utilisateur connecté
    print('Bonjour ${user.name}');
  } else {
    // Aucun utilisateur connecté
    print('Veuillez vous connecter');
  }
} catch (e) {
  // Gestion de l'erreur
  print('Erreur de récupération: $e');
}
```

---

## 📋 TaskRemoteRepository

**Fichier** : `lib/repository/task_remote_repository.dart`

**Responsabilité** : Gestion des opérations CRUD sur les tâches via l'API REST backend.

**Pattern** : Repository

### Dépendances
- `http` package pour les appels HTTP
- `TaskModel` pour la sérialisation des données
- `Constants` pour les URLs d'API

### Méthodes publiques

#### `createTask({required String name, required String description, required String date, required String time, required String priority, required String contact, required String token, String status = 'pending'})`
**Description** : Création d'une nouvelle tâche.

**Paramètres :**
- `name` : Nom de la tâche
- `description` : Description détaillée
- `date` : Date d'échéance (format string)
- `time` : Heure d'échéance (format string)
- `priority` : Priorité de la tâche
- `contact` : Contact associé
- `token` : Token d'authentification
- `status` : Statut de la tâche (défaut: 'pending')

**Retour :** `Future<TaskModel>` - Tâche créée

**Endpoint :** `POST /tasks`

**Gestion des erreurs :**
- Validation du code de statut HTTP
- Parsing des erreurs du backend
- Propagation des erreurs

**Utilisation :**
```dart
final taskRepo = TaskRemoteRepository();
try {
  final task = await taskRepo.createTask(
    name: "Appeler Amine",
    description: "Discuter du projet TaskMate",
    date: "2024-01-15",
    time: "14:00",
    priority: "High priority",
    contact: "Amine",
    token: userToken,
    status: "pending"
  );
  // Tâche créée avec succès
} catch (e) {
  // Gestion de l'erreur
  print('Erreur de création: $e');
}
```

#### `getTasks({required String token, DateTime? date})`
**Description** : Récupération des tâches avec filtrage optionnel par date.

**Paramètres :**
- `token` : Token d'authentification
- `date` : Date de filtrage (optionnel)

**Retour :** `Future<List<TaskModel>>` - Liste des tâches

**Endpoint :** `GET /tasks?date=YYYY-MM-DD`

**Fonctionnalités :**
- Filtrage optionnel par date
- Parsing automatique des dates
- Gestion des listes vides

**Utilisation :**
```dart
final taskRepo = TaskRemoteRepository();
try {
  // Récupérer toutes les tâches
  final allTasks = await taskRepo.getTasks(token: userToken);
  
  // Récupérer les tâches d'une date spécifique
  final todayTasks = await taskRepo.getTasks(
    token: userToken,
    date: DateTime.now()
  );
} catch (e) {
  // Gestion de l'erreur
  print('Erreur de récupération: $e');
}
```

#### `updateTask({required String taskId, required String name, required String description, required String date, required String time, required String priority, required String contact, required String token, String? status})`
**Description** : Mise à jour d'une tâche existante.

**Paramètres :**
- `taskId` : Identifiant unique de la tâche
- `name` : Nouveau nom
- `description` : Nouvelle description
- `date` : Nouvelle date d'échéance
- `time` : Nouvelle heure d'échéance
- `priority` : Nouvelle priorité
- `contact` : Nouveau contact
- `token` : Token d'authentification
- `status` : Nouveau statut (optionnel)

**Retour :** `Future<TaskModel>` - Tâche mise à jour

**Endpoint :** `PATCH /tasks/{taskId}`

**Fonctionnalités :**
- Mise à jour partielle des champs
- Validation des données
- Retour de la tâche mise à jour

**Utilisation :**
```dart
final taskRepo = TaskRemoteRepository();
try {
  final updatedTask = await taskRepo.updateTask(
    taskId: "task_123",
    name: "Appeler Amine - URGENT",
    description: "Discuter du projet TaskMate en priorité",
    date: "2024-01-15",
    time: "13:00",
    priority: "High priority",
    contact: "Amine",
    token: userToken,
    status: "in_progress"
  );
  // Tâche mise à jour avec succès
} catch (e) {
  // Gestion de l'erreur
  print('Erreur de mise à jour: $e');
}
```

#### `deleteTask({required String taskId, required String token})`
**Description** : Suppression d'une tâche.

**Paramètres :**
- `taskId` : Identifiant unique de la tâche
- `token` : Token d'authentification

**Retour :** `Future<void>`

**Endpoint :** `DELETE /tasks/{taskId}`

**Gestion des erreurs :**
- Validation de la suppression
- Gestion des tâches non trouvées

**Utilisation :**
```dart
final taskRepo = TaskRemoteRepository();
try {
  await taskRepo.deleteTask(
    taskId: "task_123",
    token: userToken
  );
  // Tâche supprimée avec succès
} catch (e) {
  // Gestion de l'erreur
  print('Erreur de suppression: $e');
}
```

---

## 🔧 Configuration et Constantes

### Endpoints API
```dart
// lib/core/constants/constants.dart
class ApiEndpoints {
  static String get health => '${Constants.backendUri}/health';
  static String get aiTest => '${Constants.backendUri}/tasks/ai/test';
  static String get aiCreate => '${Constants.backendUri}/tasks/ai';
  static String get auth => '${Constants.backendUri}/auth';
  static String get tasks => '${Constants.backendUri}/tasks';
}
```

### Configuration du backend
```dart
class Constants {
  static String backendUri = "http://192.168.1.5:8000";
}
```

---

## 🚀 Gestion des Erreurs

### Types d'erreurs gérés
1. **Erreurs HTTP** : Codes de statut 4xx et 5xx
2. **Erreurs de réseau** : Timeout, connexion refusée
3. **Erreurs de parsing** : Données JSON invalides
4. **Erreurs d'authentification** : Token expiré ou invalide

### Stratégie de gestion
```dart
try {
  final result = await repository.method();
  return result;
} catch (e) {
  // Log de l'erreur pour le débogage
  print('Repository error: $e');
  
  // Propagation de l'erreur vers la couche métier
  rethrow;
}
```

---

## 🧪 Tests des Repositories

### Tests unitaires
```bash
# Test d'un repository spécifique
flutter test test/repository/auth_remote_repository_test.dart

# Test de tous les repositories
flutter test test/repository/
```

### Mocking pour les tests
```dart
// Exemple de mock pour AuthRemoteRepository
class MockAuthRemoteRepository extends Mock implements AuthRemoteRepository {
  @override
  Future<UserModel> login({
    required String name,
    required String email,
    required String password,
  }) async {
    return UserModel(
      id: 'mock_id',
      name: name,
      email: email,
      phone: 'mock_phone',
      token: 'mock_token',
    );
  }
}
```

---

## 📚 Bonnes Pratiques

### 1. **Séparation des responsabilités**
- Chaque repository gère un domaine métier spécifique
- Pas de logique métier dans les repositories

### 2. **Gestion des erreurs**
- Capture et propagation appropriée des erreurs
- Messages d'erreur explicites pour le débogage

### 3. **Validation des données**
- Vérification des codes de statut HTTP
- Parsing sécurisé des réponses JSON

### 4. **Testabilité**
- Repositories facilement mockables
- Dépendances injectées plutôt que créées en interne

---

## 🔄 Intégration avec les Cubits

### Flux de données
```
UI → Cubit → Repository → API Backend
  ←        ←           ←
```

### Exemple d'intégration
```dart
// Dans AuthCubit
class AuthCubit extends Cubit<AuthState> {
  final authRemoteRepository = AuthRemoteRepository();
  
  void login({required String name, required String email, required String password}) async {
    try {
      emit(AuthLoading());
      
      final userModel = await authRemoteRepository.login(
        name: name,
        email: email,
        password: password,
      );
      
      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
```

---

**Note** : Ces repositories sont conçus pour être extensibles et maintenables. Consultez le code source pour les détails d'implémentation complets.
