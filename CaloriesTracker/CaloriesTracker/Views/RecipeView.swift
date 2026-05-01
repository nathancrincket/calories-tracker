import SwiftUI
import SwiftData

struct RecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.createdAt, order: .reverse) private var recipes: [Recipe]
    @Query(sort: \FoodItem.name) private var savedFoods: [FoodItem]

    @State private var showNewRecipeSheet = false
    @State private var selectedRecipe: Recipe?

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView(
                        "Aucune recette",
                        systemImage: "book.closed",
                        description: Text("Créez votre première recette avec le bouton +")
                    )
                } else {
                    List {
                        ForEach(recipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(recipe.name)
                                        .font(.headline)
                                    Text(String(format: "%.0f kcal · %d ingrédient(s)",
                                                recipe.totalCalories, recipe.items.count))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteRecipes)
                    }
                }
            }
            .navigationTitle("Recettes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showNewRecipeSheet = true }) {
                        Label("Nouvelle recette", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewRecipeSheet) {
                NewRecipeSheet(isPresented: $showNewRecipeSheet)
            }
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipes[index])
        }
    }
}

// MARK: - Recipe Detail

struct RecipeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodItem.name) private var savedFoods: [FoodItem]

    let recipe: Recipe

    @State private var showAddIngredientSheet = false

    var body: some View {
        List {
            Section(header: Text("Valeurs nutritionnelles totales")) {
                NutritionRow(label: "Calories", value: recipe.totalCalories, unit: "kcal")
                NutritionRow(label: "Protéines", value: recipe.totalProteins, unit: "g")
                NutritionRow(label: "Graisses", value: recipe.totalFats, unit: "g")
                NutritionRow(label: "Glucides", value: recipe.totalCarbs, unit: "g")
            }

            Section(header: Text("Ingrédients")) {
                if recipe.items.isEmpty {
                    Text("Aucun ingrédient pour l'instant.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recipe.items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.foodName)
                                    .font(.subheadline)
                                Text(String(format: "x%.1f · %.0f kcal", item.quantity, item.calories * item.quantity))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddIngredientSheet = true }) {
                    Label("Ajouter ingrédient", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddIngredientSheet) {
            AddIngredientSheet(recipe: recipe, isPresented: $showAddIngredientSheet)
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(recipe.items[index])
        }
    }
}

private struct NutritionRow: View {
    let label: String
    let value: Double
    let unit: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(String(format: "%.1f %@", value, unit))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - New Recipe Sheet

struct NewRecipeSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nom de la recette", text: $name)
                }
            }
            .navigationTitle("Nouvelle recette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let recipe = Recipe(name: trimmed)
        modelContext.insert(recipe)
        isPresented = false
    }
}

// MARK: - Add Ingredient Sheet

struct AddIngredientSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodItem.name) private var savedFoods: [FoodItem]

    let recipe: Recipe
    @Binding var isPresented: Bool

    @State private var selectedFood: FoodItem?
    @State private var quantity = "1"

    // Manual entry (when no saved foods)
    @State private var manualName = ""
    @State private var manualCalories = ""
    @State private var manualProteins = ""
    @State private var manualFats = ""
    @State private var manualCarbs = ""

    var body: some View {
        NavigationStack {
            Form {
                if !savedFoods.isEmpty {
                    Section(header: Text("Choisir un aliment enregistré")) {
                        Picker("Aliment", selection: $selectedFood) {
                            Text("Sélectionner…").tag(Optional<FoodItem>(nil))
                            ForEach(savedFoods) { food in
                                Text(food.name).tag(Optional(food))
                            }
                        }
                    }
                }

                if selectedFood == nil {
                    Section(header: Text("Ou saisir manuellement")) {
                        TextField("Nom", text: $manualName)
                        TextField("Calories (kcal)", text: $manualCalories)
                            .keyboardType(.decimalPad)
                        TextField("Protéines (g)", text: $manualProteins)
                            .keyboardType(.decimalPad)
                        TextField("Graisses (g)", text: $manualFats)
                            .keyboardType(.decimalPad)
                        TextField("Glucides (g)", text: $manualCarbs)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Quantité")) {
                    TextField("Nombre de portions", text: $quantity)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Ajouter un ingrédient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") { addIngredient() }
                }
            }
        }
    }

    private func addIngredient() {
        let qty = Double(quantity) ?? 1
        let item: RecipeItem

        if let food = selectedFood {
            item = RecipeItem(
                recipe: recipe,
                foodName: food.name,
                calories: food.calories,
                proteins: food.proteins,
                fats: food.fats,
                carbs: food.carbs,
                quantity: qty
            )
        } else {
            let name = manualName.trimmingCharacters(in: .whitespaces)
            guard !name.isEmpty else { isPresented = false; return }
            item = RecipeItem(
                recipe: recipe,
                foodName: name,
                calories: Double(manualCalories) ?? 0,
                proteins: Double(manualProteins) ?? 0,
                fats: Double(manualFats) ?? 0,
                carbs: Double(manualCarbs) ?? 0,
                quantity: qty
            )
        }
        modelContext.insert(item)
        recipe.items.append(item)
        isPresented = false
    }
}

#Preview {
    RecipeView()
        .modelContainer(for: [Recipe.self, RecipeItem.self, FoodItem.self], inMemory: true)
}
