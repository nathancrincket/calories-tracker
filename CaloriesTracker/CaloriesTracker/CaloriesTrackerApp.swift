import SwiftUI
import SwiftData

@main
struct CaloriesTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            FoodItem.self,
            MealEntry.self,
            Recipe.self,
            RecipeItem.self
        ])
    }
}
