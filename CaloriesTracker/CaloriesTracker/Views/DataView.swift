import SwiftUI
import SwiftData

struct DataView: View {
    @Query(sort: \MealEntry.date, order: .reverse) private var allEntries: [MealEntry]

    private var groupedByDay: [(date: Date, entries: [MealEntry])] {
        let calendar = Calendar.current
        var dict: [Date: [MealEntry]] = [:]
        for entry in allEntries {
            let day = calendar.startOfDay(for: entry.date)
            dict[day, default: []].append(entry)
        }
        return dict
            .map { (date: $0.key, entries: $0.value) }
            .sorted { $0.date > $1.date }
            .prefix(14)
            .map { $0 }
    }

    var body: some View {
        NavigationStack {
            Group {
                if allEntries.isEmpty {
                    ContentUnavailableView(
                        "Aucune donnée",
                        systemImage: "chart.bar",
                        description: Text("Commencez à ajouter des aliments pour voir votre suivi ici.")
                    )
                } else {
                    List {
                        ForEach(groupedByDay, id: \.date) { day in
                            Section(header: Text(day.date, style: .date)) {
                                // Calories bar indicator
                                let totalCal = day.entries.reduce(0) { $0 + $1.calories * $1.quantity }
                                let totalProt = day.entries.reduce(0) { $0 + $1.proteins * $1.quantity }
                                let totalFats = day.entries.reduce(0) { $0 + $1.fats * $1.quantity }
                                let totalCarbs = day.entries.reduce(0) { $0 + $1.carbs * $1.quantity }

                                VStack(alignment: .leading, spacing: 6) {
                                    DayStatRow(label: "Calories",  value: totalCal,   unit: "kcal", color: .orange)
                                    DayStatRow(label: "Protéines", value: totalProt,  unit: "g",    color: .blue)
                                    DayStatRow(label: "Graisses",  value: totalFats,  unit: "g",    color: .red)
                                    DayStatRow(label: "Glucides",  value: totalCarbs, unit: "g",    color: .green)
                                }
                                .padding(.vertical, 4)

                                ForEach(day.entries) { entry in
                                    HStack {
                                        Text(entry.foodName)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(String(format: "%.0f kcal", entry.calories * entry.quantity))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Données")
        }
    }
}

private struct DayStatRow: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: min(geo.size.width * barFraction, geo.size.width), height: 8)
                }
            }
            .frame(height: 8)
            Text(String(format: "%.0f %@", value, unit))
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 70, alignment: .trailing)
        }
    }

    /// Scale: 2000 kcal = 100 % for calories, 200 g for macros.
    private var barFraction: Double {
        let maxVal: Double = unit == "kcal" ? 2000 : 200
        return min(value / maxVal, 1.0)
    }
}

#Preview {
    DataView()
        .modelContainer(for: MealEntry.self, inMemory: true)
}
