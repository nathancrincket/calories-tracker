import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FoodItem.name) private var savedFoods: [FoodItem]

    // Form fields for adding a new food to the library
    @State private var newFoodName = ""
    @State private var newCalories = ""
    @State private var newProteins = ""
    @State private var newFats = ""
    @State private var newCarbs = ""

    // Add to today's log
    @State private var selectedFood: FoodItem?
    @State private var quantity = "1"
    @State private var entryDate = Date()

    @State private var showAddFoodSheet = false
    @State private var showQRPlaceholder = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            List {
                // --- Add to today's diary ---
                Section(header: Text("Ajouter au journal")) {
                    if let food = selectedFood {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(food.name)
                                    .font(.headline)
                                Spacer()
                                Button("Changer") { selectedFood = nil }
                                    .font(.caption)
                            }
                            HStack {
                                Text("Quantité (portions)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                TextField("1", text: $quantity)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                            }
                            DatePicker("Date", selection: $entryDate, displayedComponents: [.date, .hourAndMinute])
                        }
                        Button(action: addEntry) {
                            Label("Enregistrer dans le journal", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                    } else {
                        Text("Sélectionnez un aliment ci-dessous ou ajoutez-en un nouveau.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // --- Scan QR code (placeholder) ---
                Section(header: Text("Scanner")) {
                    Button(action: { showQRPlaceholder = true }) {
                        Label("Scanner un code QR / code-barres", systemImage: "qrcode.viewfinder")
                    }
                    // TODO: Implement QR / barcode scanning using AVFoundation or VisionKit
                }

                // --- Saved foods library ---
                Section(header: Text("Aliments enregistrés")) {
                    if savedFoods.isEmpty {
                        Text("Aucun aliment enregistré.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(savedFoods) { food in
                            Button(action: { selectedFood = food; quantity = "1" }) {
                                FoodRow(food: food, isSelected: selectedFood?.id == food.id)
                            }
                        }
                        .onDelete(perform: deleteFoods)
                    }
                }
            }
            .navigationTitle("Ajout")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddFoodSheet = true }) {
                        Label("Nouvel aliment", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddFoodSheet) {
                NewFoodSheet(isPresented: $showAddFoodSheet)
            }
            .alert("Scan QR Code", isPresented: $showQRPlaceholder) {
                Button("OK") {}
            } message: {
                // TODO: Replace with real QR/barcode scanner using VisionKit
                Text("La fonctionnalité de scan sera disponible prochainement.")
            }
            .alert("Erreur", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func addEntry() {
        guard let food = selectedFood else { return }
        let qty = Double(quantity) ?? 1
        guard qty > 0 else {
            alertMessage = "La quantité doit être supérieure à 0."
            showAlert = true
            return
        }
        let entry = MealEntry(
            foodName: food.name,
            calories: food.calories,
            proteins: food.proteins,
            fats: food.fats,
            carbs: food.carbs,
            quantity: qty,
            date: entryDate
        )
        modelContext.insert(entry)
        selectedFood = nil
        quantity = "1"
    }

    private func deleteFoods(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(savedFoods[index])
        }
    }
}

private struct FoodRow: View {
    let food: FoodItem
    let isSelected: Bool

    private var macroText: String {
        String(format: "%.0f kcal · P:%.1fg · L:%.1fg · G:%.1fg",
               food.calories, food.proteins, food.fats, food.carbs)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .foregroundStyle(.primary)
                Text(macroText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.accentColor)
            }
        }
    }
}

/// Sheet for creating a new FoodItem and saving it to the library.
struct NewFoodSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var isPresented: Bool

    @State private var name = ""
    @State private var calories = ""
    @State private var proteins = ""
    @State private var fats = ""
    @State private var carbs = ""
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informations")) {
                    TextField("Nom de l'aliment", text: $name)
                    TextField("Calories (kcal)", text: $calories)
                        .keyboardType(.decimalPad)
                    TextField("Protéines (g)", text: $proteins)
                        .keyboardType(.decimalPad)
                    TextField("Graisses (g)", text: $fats)
                        .keyboardType(.decimalPad)
                    TextField("Glucides (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Nouvel aliment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Données invalides", isPresented: $showAlert) {
                Button("OK") {}
            } message: {
                Text("Veuillez entrer un nom et des valeurs numériques valides.")
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty,
              let cal = Double(calories.isEmpty ? "0" : calories) else {
            showAlert = true
            return
        }
        let food = FoodItem(
            name: trimmedName,
            calories: cal,
            proteins: Double(proteins.isEmpty ? "0" : proteins) ?? 0,
            fats: Double(fats.isEmpty ? "0" : fats) ?? 0,
            carbs: Double(carbs.isEmpty ? "0" : carbs) ?? 0
        )
        modelContext.insert(food)
        isPresented = false
    }
}

#Preview {
    AddFoodView()
        .modelContainer(for: [FoodItem.self, MealEntry.self], inMemory: true)
}
