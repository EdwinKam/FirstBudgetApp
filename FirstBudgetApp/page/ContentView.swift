import SwiftUI
import CoreData
import Charts

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionItem.createdAt, ascending: false)],
        animation: .default
    ) private var items: FetchedResults<TransactionItem>
    
    @State private var selectedItem: TransactionItem?
    @State private var selectedCategory: TransactionCategory? // New state for selected category
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: NewTransaction()) {
                    Text("Click me to add new transaction")
                        .frame(width: 200, height: 40, alignment: .center)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                if !items.isEmpty {
                    PieChartView(transactionItems: Array(items), selectedCategory: $selectedCategory)
                        .frame(height: 300)
                        .padding()
                    
                    if let selectedCategory = selectedCategory {
                        HStack {
                            Text("Selected Category: \(selectedCategory.name ?? "Unknown")")
                                                            .padding()
                            Button("Reset") {
                                self.selectedCategory = nil
                            }
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    
                    TransactionList(items: items, filteredByCategory: selectedCategory)
                } else {
                    Text("No data to display")
                        .frame(height: 300)
                        .padding()
                }
            }
        }
    }
    
    private func selectedCategory(for name: String?) -> TransactionCategory? {
        guard let name = name else { return nil }
        return items.first(where: { $0.category?.name == name })?.category
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
