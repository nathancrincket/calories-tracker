import Foundation
import SwiftData

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var calories: Double
    var proteins: Double
    var fats: Double
    var carbs: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        calories: Double,
        proteins: Double = 0,
        fats: Double = 0,
        carbs: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.proteins = proteins
        self.fats = fats
        self.carbs = carbs
        self.createdAt = createdAt
    }
}
