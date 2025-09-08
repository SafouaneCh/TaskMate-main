# API Backend - TaskMate AI

## 🌐 Vue d'ensemble

L'API backend de TaskMate AI est une API REST personnalisée qui gère l'authentification, la gestion des tâches et l'intégration des services d'intelligence artificielle.

**Base URL**: `http://192.168.1.5:8000` (configurable dans `lib/core/constants/constants.dart`)

## 🔐 Authentification

### Endpoint d'inscription
```http
POST /auth/signup
```

**Corps de la requête :**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "phone": "string"
}
```

**Réponse (201 Created) :**
```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "token": "string"
}
```

### Endpoint de connexion
```http
POST /auth/login
```

**Corps de la requête :**
```json
{
  "name": "string",
  "email": "string",
  "password": "string"
}
```

**Réponse (200 OK) :**
```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "token": "string"
}
```

### Validation de token
```http
POST /auth/tokenIsValid
```

**Headers :**
```
x-auth-token: string
```

**Réponse (200 OK) :**
```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "token": "string"
}
```

## 📋 Gestion des Tâches

### Créer une tâche
```http
POST /tasks
```

**Headers :**
```
x-auth-token: string
Content-Type: application/json
```

**Corps de la requête :**
```json
{
  "name": "string",
  "description": "string",
  "date": "string",
  "time": "string",
  "priority": "string",
  "contact": "string",
  "status": "string"
}
```

**Réponse (201 Created) :**
```json
{
  "id": "string",
  "uid": "string",
  "name": "string",
  "description": "string",
  "dueAt": "string",
  "priority": "string",
  "contact": "string",
  "status": "string",
  "createdAt": "string",
  "updatedAt": "string"
}
```

### Récupérer les tâches
```http
GET /tasks?date=YYYY-MM-DD
```

**Headers :**
```
x-auth-token: string
```

**Paramètres de requête :**
- `date` (optionnel) : Date au format YYYY-MM-DD

**Réponse (200 OK) :**
```json
[
  {
    "id": "string",
    "uid": "string",
    "name": "string",
    "description": "string",
    "dueAt": "string",
    "priority": "string",
    "contact": "string",
    "status": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
]
```

### Mettre à jour une tâche
```http
PATCH /tasks/{taskId}
```

**Headers :**
```
x-auth-token: string
Content-Type: application/json
```

**Corps de la requête :**
```json
{
  "name": "string",
  "description": "string",
  "date": "string",
  "time": "string",
  "priority": "string",
  "contact": "string",
  "status": "string"
}
```

**Réponse (200 OK) :**
```json
{
  "id": "string",
  "uid": "string",
  "name": "string",
  "description": "string",
  "dueAt": "string",
  "priority": "string",
  "contact": "string",
  "status": "string",
  "createdAt": "string",
  "updatedAt": "string"
}
```

### Supprimer une tâche
```http
DELETE /tasks/{taskId}
```

**Headers :**
```
x-auth-token: string
```

**Réponse (200 OK) :**
```json
{
  "message": "Task deleted successfully"
}
```

## 🤖 Services d'Intelligence Artificielle

### Test de parsing IA
```http
POST /tasks/ai/test
```

**Headers :**
```
x-auth-token: string
Content-Type: application/json
```

**Corps de la requête :**
```json
{
  "naturalLanguageInput": "string"
}
```

**Réponse (200 OK) :**
```json
{
  "parsed": {
    "name": "string",
    "description": "string",
    "dueAt": "string",
    "priority": "string",
    "contact": "string"
  }
}
```

### Créer une tâche avec IA
```http
POST /tasks/ai
```

**Headers :**
```
x-auth-token: string
Content-Type: application/json
```

**Corps de la requête :**
```json
{
  "naturalLanguageInput": "string"
}
```

**Réponse (201 Created) :**
```json
{
  "task": {
    "id": "string",
    "uid": "string",
    "name": "string",
    "description": "string",
    "dueAt": "string",
    "priority": "string",
    "contact": "string",
    "status": "string",
    "createdAt": "string",
    "updatedAt": "string"
  }
}
```

## 🏥 Endpoint de santé
```http
GET /health
```

**Réponse (200 OK) :**
```json
{
  "status": "healthy",
  "timestamp": "string"
}
```

## 📊 Codes de statut HTTP

- **200 OK** : Requête réussie
- **201 Created** : Ressource créée avec succès
- **400 Bad Request** : Données de requête invalides
- **401 Unauthorized** : Token d'authentification manquant ou invalide
- **404 Not Found** : Ressource non trouvée
- **500 Internal Server Error** : Erreur interne du serveur

## 🔒 Sécurité

- Toutes les requêtes (sauf `/health`) nécessitent un token d'authentification
- Le token doit être inclus dans le header `x-auth-token`
- Les tokens expirent après une durée déterminée
- Validation des données d'entrée côté serveur

## 📝 Exemples d'utilisation

### Créer une tâche avec IA
```bash
curl -X POST http://192.168.1.5:8000/tasks/ai \
  -H "Content-Type: application/json" \
  -H "x-auth-token: YOUR_TOKEN" \
  -d '{"naturalLanguageInput": "Rappelle-moi d\'appeler Amine demain à 14h"}'
```

### Récupérer les tâches du jour
```bash
curl -X GET "http://192.168.1.5:8000/tasks?date=2024-01-15" \
  -H "x-auth-token: YOUR_TOKEN"
```

## 🚀 Développement

### Variables d'environnement
```bash
BACKEND_PORT=8000
DATABASE_URL=your_database_url
JWT_SECRET=your_jwt_secret
AI_SERVICE_URL=your_ai_service_url
```

### Démarrage en développement
```bash
npm install
npm run dev
```

---

**Note** : Cette API est en cours de développement et peut être modifiée. Consultez toujours la dernière version de la documentation.
