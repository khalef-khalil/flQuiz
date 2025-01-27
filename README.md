# Guide d'installation et d'exécution du projet Quiz

Ce guide vous expliquera comment configurer et exécuter le projet Quiz sur votre machine Windows. Le projet est composé d'un backend Django et d'un frontend Flutter.

## Prérequis

Avant de commencer, assurez-vous d'avoir installé les éléments suivants :

1. **Python** : Téléchargez et installez Python depuis [python.org](https://www.python.org/downloads/).
2. **Flutter** : Suivez les instructions sur [flutter.dev](https://flutter.dev/docs/get-started/install) pour installer Flutter.
3. **Android Studio** : Installez Android Studio pour émuler des appareils Android.
4. **Git** : Téléchargez et installez Git depuis [git-scm.com](https://git-scm.com/).

## Configuration du Backend (Django)

1. **Cloner le dépôt** :
   ```bash
   git clone https://github.com/khalef-khalil/flQuiz
   cd quiz/backend
   ```

2. **Activer l'environnement virtuel** :
   ```bash
   venv\Scripts\activate
   ```

3. **Installer les dépendances** :
   ```bash
   pip install -r requirements.txt
   ```

4. **Appliquer les migrations** :
   ```bash
   python manage.py migrate
   ```

5. **Créer un superutilisateur** :
   ```bash
   python manage.py createsuperuser
   ```
   Suivez les instructions pour créer un compte administrateur.

6. **Démarrer le serveur** :
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```
   Le serveur sera accessible à l'adresse `http://127.0.0.1:8000/`.

## Configuration du Frontend (Flutter)

1. **Naviguer vers le répertoire Flutter** :
   ```bash
   cd ..\flutter_front
   ```

2. **Installer les dépendances Flutter** :
   ```bash
   flutter pub get
   ```

3. **Configurer un émulateur Android** :
   - Ouvrez Android Studio.
   - Allez dans "AVD Manager" et créez un nouvel appareil virtuel.
   - Démarrez l'émulateur.

4. **Exécuter l'application Flutter** :
   ```bash
   flutter run
   ```
   Assurez-vous que l'émulateur est en cours d'exécution.

## Résolution des problèmes

- **Problèmes de chemin** : Assurez-vous que tous les chemins sont correctement configurés dans les variables d'environnement de votre système.
- **Erreurs de dépendance** : Vérifiez que toutes les dépendances sont correctement installées.
- **Problèmes d'émulateur** : Assurez-vous que l'émulateur est correctement configuré et en cours d'exécution.

## Remarques

- Ce guide suppose que vous avez une connexion Internet active pour télécharger les dépendances et les outils nécessaires.
- Pour toute question ou problème, veuillez consulter la documentation officielle de [Django](https://docs.djangoproject.com/) et [Flutter](https://flutter.dev/docs). 