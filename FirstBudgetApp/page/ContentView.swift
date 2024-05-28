import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var items: FetchedResults<TransactionItem>
    
    @State private var selectedItem: TransactionItem?
    @State private var showEditPopup: Bool = false

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
                    TransactionList(items: items)
                } else {
                    Text("No data to display")
                        .frame(height: 300)
                        .padding()
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
