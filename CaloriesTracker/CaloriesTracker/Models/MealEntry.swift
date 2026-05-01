import Foundation
import SwiftData

/// Represents a single food consumption entry for a given day.
@Model
final class MealEntry {
    var id: UUID
    var foodName: String
    var calories: Double
    var proteins: Double
    var fats: Double
    var carbs: Double
    var quantity: Double   // in grams or units, depending on the food
    var date: Date

    init(
        id: UUID = UUID(),
        foodName: String,
        calories: Double,
        proteins: Double = 0,
        fats: Double = 0,
        carbs: Double = 0,
        quantity: Double = 1,
        date: Date = Date()
    ) {
        self.id = id
        self.foodName = foodName
        self.calories = calories
        self.proteins = proteins
        self.fats = fats
        self.carbs = carbs
        self.quantity = quantity
        self.date = date
    }
}
