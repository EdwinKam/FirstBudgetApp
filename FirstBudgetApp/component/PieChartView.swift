import SwiftUI
import Charts

struct PieChartView: View {
    let transactionItems: [TransactionItem]
    @Binding var selectedCategory: String? // Binding for selected category

    private static let chartColors: [Color] = [.red, .green, .blue, .orange, .purple]

    // Computed property to calculate category totals with optional filtering
    private var categoryTotals: [String: Double] {
        var totals: [String: Double] = [:]
        
        for item in transactionItems {
            let categoryName = item.category?.name ?? "Uncategorized"
            totals[categoryName, default: 0.0] += item.amount
        }
        
        return totals
    }

    var body: some View {
        ZStack {
            Chart {
                ForEach(categoryTotals.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                    let isSelected = selectedCategory == category
                    SectorMark(
                        angle: .value("Total", total),
                        outerRadius: .ratio(isSelected ? 1 : 0.9),
                        angularInset: isSelected ? 2 : 0
                    )
                    .foregroundStyle(by: .value("Category", category))
                    .cornerRadius(3)
                    .annotation(position: .overlay, alignment: .center) {
                        VStack {
                            Text(category)
                                .font(.caption)
                                .foregroundColor(isSelected ? .yellow : .white)
                            Text("\(total, specifier: "%.2f")")
                                .font(.caption2)
                                .foregroundColor(isSelected ? .yellow : .white)
                        }
                    }
                }
            }
            .chartAngleSelection(value: $selectedCategory)
            .chartForegroundStyleScale(domain: .automatic, range: Self.chartColors)
            .onChange(of: selectedCategory) { newSelection in
                if let newSelection = newSelection {
                    print("Selected category: \(newSelection)")
                } else {
                    print("Selection cleared")
                }
            }
            .frame(height: 300)
            .animation(.bouncy, value: selectedCategory)
        }
    }
}
