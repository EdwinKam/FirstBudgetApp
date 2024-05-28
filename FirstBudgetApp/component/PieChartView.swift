import SwiftUI
import Charts

struct PieChartView: View {
    let transactionItems: [TransactionItem]
    @State var selectedCategory: TransactionCategory? // Binding for selected category
    @State var pieSelection: Double?

    private static let chartColors: [Color] = [.red, .green, .blue, .orange, .purple]

    // Computed property to calculate category totals with optional filtering
    private var categoryTotals: [String: Double] {
        var totals: [String: Double] = [:]
        
        for item in transactionItems {
            let categoryName = item.category?.name ?? "Uncategorized"
            totals[categoryName, default: 0.0] += item.amount
        }
        print("printing total")
        print(totals)
        return totals
    }

    var body: some View {
            Chart {
                ForEach(categoryTotals.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                    SectorMark(
                        angle: .value("Total", total),
                        outerRadius: 100, // Increased radius for better visibility
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Category", category))
                    .cornerRadius(3)
                }
            }
            .chartAngleSelection(value: $pieSelection)
            .frame(height: 300) // Ensure the frame is set to see the chart
            .onChange(of: pieSelection, initial: false) { oldValue, newValue in
                if let oldValue {
                    print(oldValue)
                }
            }
        }
}
