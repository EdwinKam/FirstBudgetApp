import SwiftUI
import Charts

struct BarChartView: View {
    let transactionItems: [TransactionItem]
    @State private var barSelection: Double?
    @State private var clickCount: Int = 0
    let timeRange: TimePeriod // Existing parameter for time range
    let timeRangeString: String // New parameter for time range string

    private static let chartColors: [Color] = [.red, .green, .blue, .orange, .purple]

    // Computed property to group transactions by time range
    private var groupedTransactions: [Date: Double] {
        var grouped: [Date: Double] = [:]
        let calendar = Calendar.current
        
        for item in transactionItems {
            guard let date = item.createdAt else { continue }
            
            var startOfPeriod: Date
            switch timeRange {
            case .week:
                startOfPeriod = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            case .month:
                startOfPeriod = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
            }
            
            grouped[startOfPeriod, default: 0.0] += item.amount
        }
        
        return grouped
    }
    
    // Computed property to get the total amount
    private var totalAmount: Double {
        transactionItems.reduce(0) { $0 + $1.amount }
    }
    
    // Computed property to get the last 5 periods
    private var lastFivePeriods: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        for i in 0..<5 {
            var components = DateComponents()
            switch timeRange {
            case .week:
                components.weekOfYear = -i
            case .month:
                components.month = -i
            }
            if let date = calendar.date(byAdding: components, to: Date()) {
                dates.insert(calendar.date(from: calendar.dateComponents([.year, timeRange == .week ? .weekOfYear : .month], from: date))!, at: 0)
            }
        }
        
        return dates
    }
    
    var body: some View {
        Chart {
            ForEach(lastFivePeriods, id: \.self) { date in
                let total = groupedTransactions[date] ?? 0.0
                BarMark(
                    x: .value("Date", dateFormatter.string(from: date)),
                    y: .value("Total", total)
                )
                .foregroundStyle(Self.chartColors.randomElement()!) // Random color for each bar
                .annotation(position: .top) {
                    Text(String(format: "%.2f", total))
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel() // Show the date label below each bar
            }
        }
        .chartYAxis {
            AxisMarks() { _ in
                AxisGridLine().foregroundStyle(.clear) // Hide grid lines
                AxisTick().foregroundStyle(.clear) // Hide ticks
                AxisValueLabel().foregroundStyle(.clear) // Hide labels
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(.clear) // Clear background for the plot area
                .frame(height: 150) // Reduce the height of the chart by 50%
        }
        .padding(.horizontal, 16) // Add padding on the left and right
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch timeRange {
        case .week:
            formatter.dateFormat = "MMM d"
        case .month:
            formatter.dateFormat = "MMM"
        }
        return formatter
    }
}
