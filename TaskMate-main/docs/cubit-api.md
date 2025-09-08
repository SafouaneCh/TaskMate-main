# API Cubit - TaskMate AI

## 🎯 Vue d'ensemble

Les Cubits de TaskMate AI implémentent le pattern Cubit de Flutter Bloc pour la gestion d'état de l'application. Ils gèrent l'état de l'authentification, des tâches et de la création de nouvelles tâches, offrant une approche réactive et prévisible pour la gestion des données.

## 📁 Structure des Cubits

```
cubit/
├── auth_cubit.dart           # Gestion de l'état d'authentification
├── tasks_cubit.dart          # Gestion de l'état des tâches
├── add_new_task_cubit.dart   # Gestion de l'état de création de tâches
├── auth_state.dart           # États d'authentification
├── tasks_state.dart          # États des tâches
└── add_new_task_state.dart   # États de création de tâches
```

## 🔐 AuthCubit

**Fichier** : `lib/cubit/auth_cubit.dart`

**Responsabilité** : Gestion de l'état d'authentification de l'utilisateur.

**Pattern** : Cubit (Flutter Bloc)

### Dépendances
- `AuthRemoteRepository` pour l'accès aux données d'authentification
- `SpService` pour la gestion des tokens locaux
- `OneSignalService` pour l'association des notifications

### Méthodes publiques

#### `getUserData()`
**Description** : Récupération et validation des données utilisateur au démarrage de l'application.

**Fonctionnalités :**
- Vérification automatique du token stocké
- Validation du token avec le backend
- Association de l'utilisateur avec OneSignal
- Gestion des timeouts et erreurs de connexion

**États émis :**
1. `AuthLoading()` - Chargement en cours
2. `AuthLoggedIn(userModel)` - Utilisateur connecté
3. `AuthInitial()` - Aucun utilisateur connecté
4. `AuthError(errorMessage)` - Erreur d'authentification

**Utilisation :**
```dart
final authCubit = AuthCubit();
authCubit.getUserData();

// Écouter les changements d'état
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    } else if (state is AuthLoggedIn) {
      return Text('Bonjour ${state.user.name}');
    } else if (state is AuthError) {
      return Text('Erreur: ${state.message}');
    }
    return LoginButton();
  },
)
```

#### `signUp({required String name, required String email, required String password, required String phone})`
**Description** : Inscription d'un nouvel utilisateur.

**Paramètres :**
- `name` : Nom complet de l'utilisateur
- `email` : Adresse email unique
- `password` : Mot de passe sécurisé
- `phone` : Numéro de téléphone

**États émis :**
1. `AuthLoading()` - Inscription en cours
2. `AuthSignUp()` - Inscription réussie
3. `AuthError(errorMessage)` - Erreur d'inscription

**Utilisation :**
```dart
authCubit.signUp(
  name: "John Doe",
  email: "john@example.com",
  password: "securePassword123",
  phone: "+1234567890"
);
```

#### `login({required String name, required String email, required String password})`
**Description** : Connexion d'un utilisateur existant.

**Paramètres :**
- `name` : Nom d'utilisateur
- `email` : Adresse email
- `password` : Mot de passe

**Fonctionnalités :**
- Stockage automatique du token dans SpService
- Association de l'utilisateur avec OneSignal
- Gestion des erreurs d'authentification

**États émis :**
1. `AuthLoading()` - Connexion en cours
2. `AuthLoggedIn(userModel)` - Connexion réussie
3. `AuthError(errorMessage)` - Erreur de connexion

**Utilisation :**
```dart
authCubit.login(
  name: "John Doe",
  email: "john@example.com",
  password: "securePassword123"
);
```

---

## 📋 TasksCubit

**Fichier** : `lib/cubit/tasks_cubit.dart`

**Responsabilité** : Gestion de l'état des tâches et des opérations CRUD.

**Pattern** : Cubit (Flutter Bloc)

### Dépendances
- `TaskRemoteRepository` pour l'accès aux données des tâches

### Méthodes publiques

#### `fetchTasks({required String token, required String userId, DateTime? date})`
**Description** : Récupération des tâches avec filtrage optionnel par date.

**Paramètres :**
- `token` : Token d'authentification
- `userId` : Identifiant de l'utilisateur
- `date` : Date de filtrage (optionnel)

**Fonctionnalités :**
- Tri automatique des tâches par priorité et statut
- Gestion des erreurs de récupération
- Émission d'états appropriés

**États émis :**
1. `TasksLoading()` - Chargement en cours
2. `TasksLoaded(sortedTasks)` - Tâches chargées et triées
3. `TasksError(errorMessage)` - Erreur de récupération

**Utilisation :**
```dart
final tasksCubit = TasksCubit();
tasksCubit.fetchTasks(
  token: userToken,
  userId: userId,
  date: DateTime.now()
);

// Écouter les changements d'état
BlocBuilder<TasksCubit, TasksState>(
  builder: (context, state) {
    if (state is TasksLoading) {
      return CircularProgressIndicator();
    } else if (state is TasksLoaded) {
      return ListView.builder(
        itemCount: state.tasks.length,
        itemBuilder: (context, index) {
          return TaskCard(task: state.tasks[index]);
        },
      );
    } else if (state is TasksError) {
      return Text('Erreur: ${state.message}');
    }
    return Container();
  },
)
```

#### `refreshTasks({required String token, required String userId, DateTime? date})`
**Description** : Actualisation des tâches (alias de fetchTasks pour la compatibilité).

#### `getTasks({required String token, required String userId, DateTime? date})`
**Description** : Récupération des tâches (alias de fetchTasks).

#### `sortCurrentTasks()`
**Description** : Tri des tâches actuellement chargées.

**Fonctionnalités :**
- Tri par priorité (High > Medium > Low)
- Tri par statut (completed en bas)
- Tri par date d'échéance (plus tôt en premier)

#### `refreshAndSortTasks({required String token, required String userId, DateTime? date})`
**Description** : Actualisation et tri des tâches.

#### `getTasksWithCustomSort({required String token, required String userId, DateTime? date})`
**Description** : Récupération des tâches avec tri personnalisé.

---

## ➕ AddNewTaskCubit

**Fichier** : `lib/cubit/add_new_task_cubit.dart`

**Responsabilité** : Gestion de l'état de création de nouvelles tâches.

**Pattern** : Cubit (Flutter Bloc)

### Dépendances
- `TaskRemoteRepository` pour la création de tâches

### Méthodes publiques

#### `createTask({required TaskData taskData, required String token})`
**Description** : Création d'une nouvelle tâche.

**Paramètres :**
- `taskData` : Données de la tâche à créer
- `token` : Token d'authentification

**États émis :**
1. `AddNewTaskLoading()` - Création en cours
2. `AddNewTaskSuccess(task)` - Tâche créée avec succès
3. `AddNewTaskError(errorMessage)` - Erreur de création

**Utilisation :**
```dart
final addTaskCubit = AddNewTaskCubit();
addTaskCubit.createTask(
  taskData: TaskData(
    name: "Appeler Amine",
    description: "Discuter du projet TaskMate",
    date: "2024-01-15",
    time: "14:00",
    priority: "High priority",
    contact: "Amine",
  ),
  token: userToken,
);
```

---

## 📊 États des Cubits

### AuthState
```dart
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthLoggedIn extends AuthState {
  final UserModel user;
  AuthLoggedIn(this.user);
}
class AuthSignUp extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

### TasksState
```dart
abstract class TasksState {}

class TasksInitial extends TasksState {}
class TasksLoading extends TasksState {}
class TasksLoaded extends TasksState {
  final List<TaskModel> tasks;
  TasksLoaded(this.tasks);
}
class TasksError extends TasksState {
  final String message;
  TasksError(this.message);
}
```

### AddNewTaskState
```dart
abstract class AddNewTaskState {}

class AddNewTaskInitial extends AddNewTaskState {}
class AddNewTaskLoading extends AddNewTaskState {}
class AddNewTaskSuccess extends AddNewTaskState {
  final TaskModel task;
  AddNewTaskSuccess(this.task);
}
class AddNewTaskError extends AddNewTaskState {
  final String message;
  AddNewTaskError(this.message);
}
```

---

## 🔄 Cycle de vie des Cubits

### 1. **Initialisation**
```dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());
  // Initialisation des dépendances
}
```

### 2. **Émission d'états**
```dart
void getUserData() async {
  try {
    emit(AuthLoading());           // État de chargement
    // ... logique métier
    emit(AuthLoggedIn(userModel)); // État de succès
  } catch (e) {
    emit(AuthError(e.toString())); // État d'erreur
  }
}
```

### 3. **Écoute des états**
```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    // Construction de l'UI selon l'état
  },
)
```

---

## 🧪 Tests des Cubits

### Tests unitaires
```bash
# Test d'un Cubit spécifique
flutter test test/cubit/auth_cubit_test.dart

# Test de tous les Cubits
flutter test test/cubit/
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

// Test du Cubit
void main() {
  group('AuthCubit', () {
    late AuthCubit authCubit;
    late MockAuthRemoteRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRemoteRepository();
      authCubit = AuthCubit();
    });

    test('initial state is AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    test('emits [AuthLoading, AuthLoggedIn] when login succeeds', () async {
      // Arrange
      when(mockRepository.login(...)).thenAnswer((_) async => mockUser);

      // Act
      authCubit.login(name: 'John', email: 'john@test.com', password: 'pass');

      // Assert
      expect(authCubit.state, isA<AuthLoading>());
      await untilCalled(() => mockRepository.login(...));
      expect(authCubit.state, isA<AuthLoggedIn>());
    });
  });
}
```

---

## 📚 Bonnes Pratiques

### 1. **Gestion des états**
- Chaque action émet un état clair et prévisible
- États immutables pour éviter les effets de bord
- Gestion appropriée des états de chargement et d'erreur

### 2. **Séparation des responsabilités**
- Chaque Cubit gère un domaine métier spécifique
- Pas de logique métier complexe dans les Cubits
- Délégation des opérations aux repositories

### 3. **Gestion des erreurs**
- Capture et gestion appropriée de toutes les exceptions
- États d'erreur informatifs pour l'utilisateur
- Logs d'erreur pour le débogage

### 4. **Performance**
- Émission d'états uniquement quand nécessaire
- Éviter les émissions d'état dans les builders
- Utilisation appropriée de BlocBuilder vs BlocListener

---

## 🔗 Intégration avec l'UI

### BlocProvider
```dart
BlocProvider<AuthCubit>(
  create: (context) => AuthCubit(),
  child: LoginScreen(),
)
```

### BlocBuilder
```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    // Construction de l'UI selon l'état
  },
)
```

### BlocListener
```dart
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    // Actions à effectuer lors des changements d'état
    if (state is AuthLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  },
  child: LoginForm(),
)
```

---

## 🚀 Avantages des Cubits

### 1. **Simplicité**
- Plus simple que Bloc pour des cas d'usage basiques
- Moins de boilerplate code
- Courbe d'apprentissage rapide

### 2. **Réactivité**
- UI mise à jour automatiquement lors des changements d'état
- Gestion réactive des données
- Performance optimisée

### 3. **Testabilité**
- États facilement testables
- Logique métier isolée
- Mocking simple des dépendances

### 4. **Maintenabilité**
- Code organisé et structuré
- Séparation claire des responsabilités
- Facile à déboguer et maintenir

---

**Note** : Les Cubits de TaskMate AI sont conçus pour être simples, performants et maintenables. Consultez le code source pour les détails d'implémentation complets.
