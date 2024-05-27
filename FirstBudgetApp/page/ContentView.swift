import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var items: FetchedResults<TransactionItem>
    
    private var categoryTotals: [String: Double] {
        Dictionary(grouping: items, by: { $0.category?.name ?? "No Category" })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: NewTransaction()) {
                    Text("Click me to add new transaction")
                        .frame(width: 200, height: 40, alignment: .center)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                if !categoryTotals.isEmpty {
                    PieChartView(categoryTotals: categoryTotals)
                        .frame(height: 300)
                        .padding()
                } else {
                    Text("No data to display")
                        .frame(height: 300)
                        .padding()
                }
                List {
                    ForEach(items) { item in
                        NavigationLink(destination: TransactionDetailView(transaction: item)) {
                            HStack {
                                Text("\(item.transactionDescription ?? "No Description")")
                                Spacer()
                                Text("\(item.amount, specifier: "%.2f")")
                                Spacer()
                                Text("\(item.category?.name ?? "No Category")")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TransactionDetailView: View {
    var transaction: TransactionItem
    
    var body: some View {
        VStack {
            Text("Description: \(transaction.transactionDescription ?? "No Description")")
            Text("Amount: \(transaction.amount, specifier: "%.2f")")
            Text("Category: \(transaction.category?.name ?? "No Category")")
        }
        .navigationTitle("Transaction Details")
        .padding()
    }
}

struct PieChartView: View {
    let categoryTotals: [String: Double]
    
    var body: some View {
        Chart {
            ForEach(categoryTotals.sorted(by: { $0.key < $1.key }), id: \.key) { category, total in
                SectorMark(
                    angle: .value("Total", total),
                    innerRadius: .ratio(0.5),
                    outerRadius: .ratio(1.0)
                )
                .foregroundStyle(by: .value("Category", category))
                .annotation(position: .overlay, alignment: .center) {
                    VStack {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("\(total, specifier: "%.2f")")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .chartLegend(.visible)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
