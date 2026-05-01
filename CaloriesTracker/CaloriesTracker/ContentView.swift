import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }

            AddFoodView()
                .tabItem {
                    Label("Ajout", systemImage: "plus.circle.fill")
                }

            RecipeView()
                .tabItem {
                    Label("Recette", systemImage: "book.fill")
                }

            DataView()
                .tabItem {
                    Label("Données", systemImage: "chart.bar.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            FoodItem.self,
            MealEntry.self,
            Recipe.self,
            RecipeItem.self
        ], inMemory: true)
}
