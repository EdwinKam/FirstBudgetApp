import SwiftUI
import Charts

struct PieChartView: View {
    let transactionItems: [TransactionItem]
    @Binding var selectedCategory: TransactionCategory? // Binding for selected category
    @State var pieSelection: Double?

    private static let chartColors: [Color] = [.red, .green, .blue, .orange, .purple]

    // Computed property to calculate category totals with optional filtering
    private var categoryTotals: [TransactionCategory: Double] {
        var totals: [TransactionCategory: Double] = [:]
        
        for item in transactionItems {
            if let category = item.category {
                totals[category, default: 0.0] += item.amount
            }
        }
        print("printing total")
        print(totals)
        return totals
    }

    var body: some View {
        Chart {
            ForEach(categoryTotals.sorted(by: { ($0.key.name ?? "") < ($1.key.name ?? "") }), id: \.key) { category, total in
                SectorMark(
                    angle: .value("Total", total),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Category", category.name ?? "Unknown"))
                .cornerRadius(3)
            }
        }
        .chartAngleSelection(value: $pieSelection)
        .frame(height: 300) // Ensure the frame is set to see the chart
        .onChange(of: pieSelection, initial: false) { oldValue, newValue in
            if let oldAngle = oldValue {
                if let selectedCategory = determineSelectedCategory(from: oldAngle) {
                    print("Selected Category: \(selectedCategory.name ?? "Unknown")")
                    self.selectedCategory = selectedCategory
                }
            }
        }
    }
    
    private func determineSelectedCategory(from angle: Double) -> TransactionCategory? {
        // Find the category that corresponds to the angle
        let sortedTotals = categoryTotals.sorted { ($0.key.name ?? "") < ($1.key.name ?? "") }
        var accumulatedAngle: Double = 0

        for (category, total) in sortedTotals {
            accumulatedAngle += total
            if angle <= accumulatedAngle {
                return category
            }
        }
        return nil
    }
}
