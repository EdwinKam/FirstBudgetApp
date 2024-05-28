import SwiftUI
import Charts

struct PieChartView: View {
    let transactionItems: [TransactionItem]
    @Binding var selectedCategory: TransactionCategory? // Binding for selected category
    @State var pieSelection: Double?
    @State var clickCount: Int = 0

    private static let chartColors: [Color] = [.red, .green, .blue, .orange, .purple]

    // Computed property to calculate category totals with optional filtering
    private var categoryTotals: [TransactionCategory: Double] {
        var totals: [TransactionCategory: Double] = [:]
        
        for item in transactionItems {
            if let category = item.category {
                totals[category, default: 0.0] += item.amount
            }
        }
        return totals
    }

    var body: some View {
        Chart {
            ForEach(categoryTotals.sorted(by: { ($0.key.name ?? "") < ($1.key.name ?? "") }), id: \.key) { category, total in
                let isSelected = selectedCategory == category
                let outerRadius = isSelected ? 110 : 100 // Change radius if selected
                let innerRadius = isSelected ? 40 : 50   // Change inner radius if selected
                
                SectorMark(
                    angle: .value("Total", total),
                    innerRadius: MarkDimension(integerLiteral: innerRadius),
                    outerRadius: MarkDimension(integerLiteral: outerRadius),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Category", category.name ?? "Unknown"))
                .cornerRadius(3)
            }
        }
        .chartAngleSelection(value: $pieSelection)
        .frame(height: 300) // Ensure the frame is set to see the chart
        .onChange(of: pieSelection, initial: false) { oldValue, newValue in
            clickCount += 1
            print("Clicked \(clickCount)")
            if let newValue {
                withAnimation {
                    if let selectedCategory = determineSelectedCategory(from: newValue) {
                        print("Selected Category: \(selectedCategory.name ?? "Unknown")")
                        self.selectedCategory = selectedCategory
                    }
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
