import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \RecipeItem.recipe)
    var items: [RecipeItem]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.items = []
    }

    /// Total calories for all items in the recipe.
    var totalCalories: Double {
        items.reduce(0) { $0 + $1.calories * $1.quantity }
    }

    /// Total proteins for all items in the recipe.
    var totalProteins: Double {
        items.reduce(0) { $0 + $1.proteins * $1.quantity }
    }

    /// Total fats for all items in the recipe.
    var totalFats: Double {
        items.reduce(0) { $0 + $1.fats * $1.quantity }
    }

    /// Total carbs for all items in the recipe.
    var totalCarbs: Double {
        items.reduce(0) { $0 + $1.carbs * $1.quantity }
    }
}
