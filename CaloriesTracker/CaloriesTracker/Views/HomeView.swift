import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var allEntries: [MealEntry]

    private var todayEntries: [MealEntry] {
        let calendar = Calendar.current
        return allEntries.filter { calendar.isDateInToday($0.date) }
    }

    private var totalCalories: Double { todayEntries.reduce(0) { $0 + $1.calories * $1.quantity } }
    private var totalProteins: Double { todayEntries.reduce(0) { $0 + $1.proteins * $1.quantity } }
    private var totalFats: Double     { todayEntries.reduce(0) { $0 + $1.fats * $1.quantity } }
    private var totalCarbs: Double    { todayEntries.reduce(0) { $0 + $1.carbs * $1.quantity } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Daily summary card
                    VStack(spacing: 16) {
                        Text("Résumé du jour")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 16) {
                            SummaryCard(label: "Calories", value: String(format: "%.0f", totalCalories), unit: "kcal", color: .orange)
                            SummaryCard(label: "Protéines", value: String(format: "%.1f", totalProteins), unit: "g", color: .blue)
                        }
                        HStack(spacing: 16) {
                            SummaryCard(label: "Graisses", value: String(format: "%.1f", totalFats), unit: "g", color: .red)
                            SummaryCard(label: "Glucides", value: String(format: "%.1f", totalCarbs), unit: "g", color: .green)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)

                    // Today's entries list
                    if !todayEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Aliments du jour")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(todayEntries) { entry in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.foodName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("x\(String(format: "%.1f", entry.quantity))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(String(format: "%.0f kcal", entry.calories * entry.quantity))
                                        .font(.subheadline)
                                        .foregroundStyle(.orange)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.systemBackground))
                                Divider()
                                    .padding(.leading)
                            }
                        }
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    } else {
                        ContentUnavailableView(
                            "Aucun aliment aujourd'hui",
                            systemImage: "fork.knife",
                            description: Text("Ajoutez des aliments via l'onglet Ajout")
                        )
                        .padding(.top, 40)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Accueil")
        }
    }
}

private struct SummaryCard: View {
    let label: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .modelContainer(for: MealEntry.self, inMemory: true)
}
