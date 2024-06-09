import SwiftUI
import Charts

struct BarChartView: View {
    let transactionItems: [TransactionItem]
    @Binding var currentDate: Date // Binding for current date
    @State private var barSelection: String?
    @State private var selectedBarSelection: String?
    @State private var clickCount: Int = 0
    let timeRange: TimePeriod // Existing parameter for time range
    let timeRangeString: String // New parameter for time range string

    private static let defaultChartColor: Color = .gray // Default grey color
    private static let selectedChartColor: Color = .green // Selected green color

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
                dates.insert(startOfTimeRange(for: timeRange, from: date), at: 0)
            }
        }
            
        return dates
    }
    
    var body: some View {
        Chart {
            ForEach(lastFivePeriods, id: \.self) { date in
                let total = groupedTransactions[date] ?? 0.0
                BarMark(
                    x: .value("Date", yyyymmddFormatter.string(from: date)),
                    y: .value("Total", total)
                )
                .foregroundStyle(selectedBarSelection == yyyymmddFormatter.string(from: date) ? Self.selectedChartColor : Self.defaultChartColor) // Change color if selected
                .annotation(position: .top) {
                    Text(String(format: "%.2f", total))
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                if let dateValue = value.as(String.self) {
                    AxisValueLabel {
                        Text(monthFromDateString(yyyymmdd: dateValue) ?? "")
                    }
                }
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
        .chartXSelection(value: $barSelection)
        .onChange(of: barSelection, initial: false) { oldValue, newValue in
            if let newValue {
                currentDate = dateFromString(yyyymmdd: newValue) ?? Date()
                selectedBarSelection = barSelection
            }
        }
        .onChange(of: timeRange, initial: true ) { _, _ in
            selectedBarSelection = findSelectedBarSelection(for: currentDate)
        }
    }
    
    func findSelectedBarSelection(for date: Date) -> String? {
        let calendar = Calendar.current
        var startOfPeriod: Date
        switch timeRange {
        case .week:
            startOfPeriod = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        case .month:
            startOfPeriod = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        }
        return yyyymmddFormatter.string(from: startOfPeriod)
    }
    
    func dateFromString(yyyymmdd: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd" // Define the date format
        return formatter.date(from: yyyymmdd)
    }
    
    func monthFromDateString(yyyymmdd: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyyMMdd" // Define the input date format

        if let date = inputFormatter.date(from: yyyymmdd) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM" // Format to get the short month name
            return outputFormatter.string(from: date)
        } else {
            return nil // Return nil if the date string is invalid
        }
    }
    
    private var yyyymmddFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd" // Format dates as "yyyymmdd"
        return formatter
    }
    
    // copy from contentView
    private func startOfTimeRange(for timePeriod: TimePeriod, from date: Date) -> Date {
        let calendar = Calendar.current
        
        switch timePeriod {
        case .week:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        }
    }
}
