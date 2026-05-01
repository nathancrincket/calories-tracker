# calories-tracker

Application iOS personnelle de suivi des calories, construite avec **SwiftUI** et **SwiftData**.

## Fonctionnalités

- 🏠 **Accueil** – Résumé journalier (calories, protéines, graisses, glucides)
- ➕ **Ajout** – Ajouter des aliments manuellement ou via scan QR *(placeholder)*
- 📖 **Recette** – Créer et gérer des recettes composées de plusieurs aliments
- 📊 **Données** – Suivi graphique des 14 derniers jours

## Stack technique

| Élément | Choix |
|---|---|
| UI | SwiftUI |
| Persistance | SwiftData |
| Cible iOS | iOS 17.0+ |
| Langage | Swift 5.9+ |

## Structure du projet

```
CaloriesTracker/
├── CaloriesTracker.xcodeproj/   ← Ouvrir dans Xcode
└── CaloriesTracker/
    ├── CaloriesTrackerApp.swift  ← Point d'entrée + ModelContainer
    ├── ContentView.swift         ← TabView (4 onglets)
    ├── Models/
    │   ├── FoodItem.swift        ← Aliment de référence
    │   ├── MealEntry.swift       ← Entrée journalière consommée
    │   ├── Recipe.swift          ← Recette
    │   └── RecipeItem.swift      ← Ingrédient d'une recette
    └── Views/
        ├── HomeView.swift        ← Résumé du jour
        ├── AddFoodView.swift     ← Ajout d'aliments
        ├── RecipeView.swift      ← Gestion des recettes
        └── DataView.swift        ← Historique des données
```

## Lancer l'application dans Xcode

1. **Cloner** le dépôt :
   ```bash
   git clone https://github.com/nathancrincket/calories-tracker.git
   ```

2. **Ouvrir** le projet dans Xcode :
   ```
   Fichier > Ouvrir… > CaloriesTracker/CaloriesTracker.xcodeproj
   ```
   *(ou double-cliquer sur `CaloriesTracker.xcodeproj`)*

3. **Sélectionner** un simulateur ou ton iPhone comme destination.

4. **Lancer** avec `⌘R`.

> **Pré-requis :** Xcode 15+ et macOS Sonoma ou Ventura (pour SwiftData complet).

## Installer sur iPhone physique

1. Dans Xcode, aller dans **Signing & Capabilities** de la cible `CaloriesTracker`.
2. Cocher **Automatically manage signing** et sélectionner ton équipe (compte Apple ID personnel).
3. Connecter l'iPhone via USB.
4. Sélectionner l'iPhone comme destination et appuyer sur `⌘R`.
5. Sur l'iPhone : **Réglages > Général > Gestion des VPN et apps** → faire confiance au développeur.

## Fonctionnalités à venir

- [ ] Scan de code QR / code-barres via l'API Open Food Facts
- [ ] Objectifs nutritionnels personnalisés (calories cibles, macros)
- [ ] Graphiques de tendances (Charts framework)
- [ ] Export CSV des données
