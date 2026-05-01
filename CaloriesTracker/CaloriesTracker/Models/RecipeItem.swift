import Foundation
import SwiftData

/// Links a food to a recipe with a specific quantity (number of portions/units).
@Model
final class RecipeItem {
    var id: UUID
    var recipe: Recipe?
    var foodName: String
    var calories: Double   // per unit
    var proteins: Double   // per unit
    var fats: Double       // per unit
    var carbs: Double      // per unit
    var quantity: Double   // number of units in the recipe

    init(
        id: UUID = UUID(),
        recipe: Recipe? = nil,
        foodName: String,
        calories: Double,
        proteins: Double = 0,
        fats: Double = 0,
        carbs: Double = 0,
        quantity: Double = 1
    ) {
        self.id = id
        self.recipe = recipe
        self.foodName = foodName
        self.calories = calories
        self.proteins = proteins
        self.fats = fats
        self.carbs = carbs
        self.quantity = quantity
    }
}
