import SwiftUI
import Charts

struct PieChartView: View {
    let transactionItems: [TransactionItem]
    @Binding var selectedCategory: TransactionCategory? // Binding for selected category
    @State var pieSelection: Double?
    @State var clickCount: Int = 0
    let timeRange: TimePeriod // Existing parameter for time range
    let timeRangeString: String // New parameter for time range string

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

    // Computed property to get the total amount
    private var totalAmount: Double {
        transactionItems.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            Chart {
                ForEach(categoryTotals.sorted(by: { ($0.key.name ?? "") < ($1.key.name ?? "") }), id: \.key) { category, total in
                    let isSelected = selectedCategory == category
                    let outerRadius = isSelected ? 160 : 140 // Change radius if selected
                    let innerRadius = isSelected ? 90 : 80   // Change inner radius if selected
                    
                    SectorMark(
                        angle: .value("Total", total),
                        innerRadius: MarkDimension(integerLiteral: innerRadius),
                        outerRadius: MarkDimension(integerLiteral: outerRadius),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", category.name ?? "Unknown"))
                    .cornerRadius(3)
                    .annotation(position: .overlay, alignment: .center) {
                        Text(category.name ?? "Unknown")
                            .font(.caption)
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(0)) // Rotate to align with the sector
                    }
                }
            }
            .chartAngleSelection(value: $pieSelection)
            .chartLegend(.hidden)
            .frame(height: 300) // Ensure the frame is set to see the chart
            .onChange(of: pieSelection, initial: false) { oldValue, newValue in
                clickCount += 1
                print("Clicked \(clickCount)")
                withAnimation {
                    if let newValue {
                        let newCategory = determineSelectedCategory(from: newValue)
                        
                        if self.selectedCategory == newCategory {
                            // Deselect if the same category is clicked again
                            self.selectedCategory = nil
                        } else {
                            // Select the new category
                            self.selectedCategory = newCategory
                        }
                        print("Selected Category: \(self.selectedCategory?.name ?? "None")")
                    }
                }
            }
            
            // Overlay the total amount and category name in the middle of the chart
            VStack {
                if let selectedCategory = selectedCategory, let total = categoryTotals[selectedCategory] {
                    Text("\(selectedCategory.name ?? "Unknown")")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("\(total, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.semibold)
                } else {
                    Text(timeRangeString)
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("\(totalAmount, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
            .cornerRadius(10)
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
