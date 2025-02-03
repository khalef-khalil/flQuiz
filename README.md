# Application de Quiz - Documentation Complète

## Table des matières
1. [Introduction](#introduction)
2. [Fonctionnalités](#fonctionnalités)
3. [Architecture](#architecture)
4. [Installation et Configuration](#installation-et-configuration)
5. [Structure des Fichiers](#structure-des-fichiers)
6. [Guide d'Utilisation](#guide-dutilisation)
7. [Détails Techniques](#détails-techniques)

## Introduction

Cette application est une plateforme complète de quiz développée avec Django (backend) et Flutter (frontend). Elle permet aux utilisateurs de créer, gérer et participer à des quiz interactifs avec différents niveaux de difficulté et catégories.

## Fonctionnalités

### 1. Gestion des Utilisateurs
- **Inscription**: Création de compte avec nom d'utilisateur, email et mot de passe
- **Connexion**: Authentification sécurisée avec token
- **Profil Utilisateur**: 
  - Affichage des statistiques personnelles
  - Historique des quiz complétés
  - Score moyen et progression

### 2. Gestion des Quiz
- **Création de Quiz**:
  - Titre et description
  - Sélection de catégorie
  - Niveau de difficulté (Facile, Moyen, Difficile)
  - Limite de temps
  - Questions multiples avec choix de réponses

- **Participation aux Quiz**:
  - Interface interactive
  - Minuteur
  - Affichage des questions et choix
  - Navigation entre les questions
  - Soumission des réponses

- **Résultats**:
  - Score final
  - Réponses correctes/incorrectes
  - Détails des réponses
  - Historique des tentatives

### 3. Gestion des Catégories
- Création de catégories personnalisées
- Attribution de quiz aux catégories
- Filtrage des quiz par catégorie

## Architecture

### Backend (Django)

#### Models
1. **User**: Modèle utilisateur standard Django
2. **UserProfile**: 
   - Statistiques utilisateur
   - Nombre de quiz complétés
   - Score moyen

3. **Quiz**:
   ```python
   class Quiz:
     - title: CharField
     - description: TextField
     - difficulty: CharField (choix: facile, moyen, difficile)
     - time_limit: IntegerField
     - category: ForeignKey(Category)
     - user: ForeignKey(User)
   ```

4. **Question**:
   ```python
   class Question:
     - quiz: ForeignKey(Quiz)
     - text: CharField
     - order: IntegerField
   ```

5. **Choice**:
   ```python
   class Choice:
     - question: ForeignKey(Question)
     - text: CharField
     - is_correct: BooleanField
   ```

#### API Endpoints
- `/api/register/`: Inscription
- `/api/login/`: Connexion
- `/api/quizzes/`: CRUD des quiz
- `/api/categories/`: CRUD des catégories
- `/api/results/`: Gestion des résultats

### Frontend (Flutter)

#### Controllers
1. **AuthController**: 
   - Gestion de l'authentification
   - Stockage du token
   - État de connexion

2. **QuizController**:
   - Gestion des quiz
   - État du quiz en cours
   - Soumission des réponses

3. **CategoryController**:
   - Gestion des catégories
   - Filtrage des quiz

#### Pages Principales
1. **LoginPage**: Page de connexion
2. **RegisterPage**: Page d'inscription
3. **HomePage**: Liste des quiz disponibles
4. **QuizPage**: Interface du quiz
5. **ResultPage**: Affichage des résultats
6. **ProfilePage**: Profil utilisateur
7. **CategoryPage**: Gestion des catégories

## Installation et Configuration

### Prérequis
- Python 3.8+
- Flutter SDK
- Android Studio / Émulateur Android
- Git

### Backend (Django)
1. **Cloner le dépôt**:
   ```bash
   git clone https://github.com/khalef-khalil/flQuiz
   cd quiz/backend
   ```

2. **Activer l'environnement virtuel**:
   ```bash
   venv\Scripts\activate
   ```

3. **Installer les dépendances**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Appliquer les migrations**:
   ```bash
   python manage.py migrate
   ```

5. **Créer un superutilisateur**:
   ```bash
   python manage.py createsuperuser
   ```

6. **Lancer le serveur**:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

### Frontend (Flutter)
1. **Naviguer vers le dossier frontend**:
   ```bash
   cd ../flutter_front
   ```

2. **Installer les dépendances**:
   ```bash
   flutter pub get
   ```

3. **Lancer l'application**:
   ```bash
   flutter run
   ```

## Structure des Fichiers

### Backend
```
backend/
├── quiz/
│   ├── models.py      # Modèles de données
│   ├── views.py       # Logique des vues
│   ├── serializers.py # Sérialiseurs API
│   ├── urls.py        # Configuration des URLs
│   └── admin.py       # Interface admin
```

### Frontend
```
flutter_front/
├── lib/
│   ├── models/        # Modèles de données
│   ├── services/      # Services API
│   └── presentation/
│       ├── pages/     # Écrans de l'application
│       ├── widgets/   # Composants réutilisables
│       └── controllers/ # Contrôleurs GetX
```

## Guide d'Utilisation

### Création d'un Quiz
1. Se connecter à l'application
2. Accéder à "Créer un Quiz"
3. Remplir les informations:
   - Titre et description
   - Sélectionner une catégorie
   - Définir la difficulté
   - Ajouter des questions et réponses

### Participation à un Quiz
1. Sélectionner un quiz sur la page d'accueil
2. Lire les instructions et commencer
3. Répondre aux questions dans le temps imparti
4. Soumettre les réponses
5. Consulter les résultats détaillés

## Détails Techniques

### Sécurité
- Authentification par token
- Validation des données côté serveur
- Protection CSRF
- Gestion des permissions

### Performance
- Mise en cache des données
- Chargement optimisé des images
- Pagination des résultats

### État de l'Application
- Gestion d'état avec GetX
- Stockage local avec GetStorage
- Gestion des erreurs et exceptions

## Support et Contact

Pour toute question ou problème:
- Créer une issue sur GitHub
- Consulter la documentation Django/Flutter
- Contacter l'équipe de développement 