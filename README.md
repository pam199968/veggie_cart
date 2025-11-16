# veggie_cart

VeGGie Cart — application Flutter pour la gestion d'un panier maraîcher.

Ce README vise les développeurs souhaitant contribuer au projet : configuration, architecture, bonnes pratiques et processus de contribution.

## Table des matières
- Prérequis
- Installation locale
- Structure du projet
- Internationalisation
- Exécution et tests
- Conventions de code
- Contribution (workflow & checklist)
- Débogage courant et FAQ

## Prérequis
- Flutter SDK (stable) — version compatible avec le projet. Vérifiez `pubspec.yaml` pour les versions des dépendances.
- Dart (inclus avec Flutter)
- (Optionnel) Firebase CLI si vous travaillez avec les services Firebase locaux

Assurez-vous d'avoir configuré les variables d'environnement et outils habituels (Android SDK, Xcode si besoin pour iOS).

## Installation locale
1. Récupérer les dépendances :

```bash
flutter pub get
```

2. (Optionnel) Génération des fichiers de localisation si vous modifiez `lib/l10n/*.arb` :

```bash
flutter gen-l10n
```

3. Lancer l'application en mode debug :

```bash
flutter run -d chrome   # pour web
flutter run -d emulator # pour Android (ou utilisez un device id)
```

4. Pour builder la version web :

```bash
flutter build web
```

## Structure du projet (aperçu)
- `lib/` : code source principal
	- `views/` ou `screens/` : widgets d'interface (pages)
	- `viewmodels/` : logique MVVM (ChangeNotifier)
	- `models/` : définitions des modèles de données
	- `repositories/` : accès aux services (ex. Firebase)
	- `l10n/` : fichiers ARB et classes de localisation générées
	- `utils/`, `extensions/` : helpers et extensions utilitaires
- `test/` : tests unitaires et widget
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` : cibles platform

Note : le projet suit une approche MVVM légère avec `ChangeNotifier` + `Provider`.

## Internationalisation
Le projet utilise les fichiers ARB situés dans `lib/l10n/` et la génération `gen_l10n`. Les helpers sont exposés via `context.l10n` (extension dans `lib/extensions/context_extension.dart`).

Si vous ajoutez ou modifiez des clés :

```bash
# modifier les fichiers ARB (ex. app_en.arb / app_fr.arb)
flutter gen-l10n
```

Les fichiers générés (`app_localizations_*.dart`) sont déjà inclus dans le repo. Respectez les conventions ARB (pas de clés dupliquées, placeholders correctement typés).

## Description fonctionnelle
Cette application permet de gérer un panier maraîcher (catalogue de légumes, offres hebdomadaires et commandes des clients) depuis une interface web/mobile.

Utilisateurs principaux :
- Administrateur / maraîcher : gestion du catalogue (ajout/modification/suppression de légumes), gestion des offres hebdomadaires, visualisation et préparation des commandes clients, gestion des méthodes de livraison.
- Client : consultation des offres, ajout d'articles au panier, finalisation de la commande (choix méthode de livraison, ajout d'adresse et notes), consultation de ses commandes.

Parcours principaux :
- Catalogue : l'administrateur peut créer/éditer des légumes (nom, description, catégorie, packaging, prix, image). Les légumes sont affichés avec prix, unité et état (actif/inactif).
- Offres hebdomadaires : l'administrateur compose des offres en sélectionnant des légumes et en définissant des plages de dates. Les clients voient les offres publiées et peuvent commander.
- Commandes : un client finalise un panier, choisit une méthode de livraison et envoie la commande. L'administrateur voit les commandes et peut gérer leur préparation et état.
- Authentification : les utilisateurs se connectent via Firebase Auth (compte existant / création de compte). Le ViewModel gère la logique d'inscription/connexion et la synchronisation avec les formulaires.

Données et persistance :
- Les données principales (légumes, offres, méthodes de livraison, commandes, utilisateurs) sont persistées via Firestore (ou tout autre backend implémenté dans `repositories/`).
- Les images sont uploadées via `ImagePickerUploader` et stockées (URL) dans le modèle `VegetableModel`.

Cas d'utilisation avancés / scénarios non-fonctionnels :
- Notifications par e-mail (pushNotifications) pour prévenir les clients d'une offre ou d'une commande.
- Import/export ou synchronisation hors-ligne (potentiel d'amélioration).


## Exécution et tests
- Analyse statique :

```bash
flutter analyze
```

- Tests unitaires / widget :

```bash
flutter test
```

- Linter : le projet suit les règles définies dans `analysis_options.yaml`. Avant d'ouvrir une PR, assurez-vous que `flutter analyze` passe.

## Conventions de code
- Dart formatting : utilisez `dart format .` avant commit.
- Noms : fichiers `snake_case`, classes `UpperCamelCase`.
- Widgets : widgets réutilisables dans `views/` ou `widgets/`.
- State management : `ChangeNotifier` + `Provider` pour la plupart des écrans.
- Localisation : texte utilisateur via `context.l10n.xx` ou les ARB; éviter les littéraux dans les widgets.

### Tests et qualité
- Ajoutez des tests unitaires pour la logique dans `viewmodels/` et des tests widget pour les composants UI critiques.
- Cible minimale dans une PR : 1 test additionnel pour une nouvelle fonctionnalité ou bug fixe si pertinent.

## Contribution — workflow recommandé
1. Fork -> créez une branche feature/bugfix : `git checkout -b feat/ma-fonctionnalite`
2. Implémentez la fonctionnalité; exécutez `flutter analyze` et `flutter test` localement.
3. Formatez le code : `dart format .`
4. Push et ouvrez une Pull Request en décrivant :
	 - But de la PR
	 - Modifications principales
	 - Étapes pour tester localement
	 - Screenshots si UI

Checklist PR (à cocher avant review) :
- [ ] Le code compile et les tests passent
- [ ] `flutter analyze` sans erreurs (ou explication pour les avertissements existants)
- [ ] Les chaînes UI sont localisées (ARB) ou justifiées
- [ ] Ajout/modification de tests si applicable

## Débogage courant
- Problème d'authentification Firebase : vérifiez `android/google-services.json` / `ios/GoogleService-Info.plist` et la configuration Firebase.
- Problème de localisation : régénérez les fichiers via `flutter gen-l10n`.
- Erreur d'analyse/linter : exécutez `flutter analyze` et corrigez les erreurs affichées.

## Points d'attention / améliorations possibles
- Externaliser les labels d'enum (`VegetableCategory.label`) pour qu'ils suivent la localisation.
- Ajouter des tests d'intégration pour les flux Firebase (p. ex. en utilisant des doubles/mocks).

## Contacts
Pour toute question, créez une issue ou mentionnez @pam199968 dans la PR.

---
Merci de contribuer — lisez la checklist avant de soumettre une PR.
