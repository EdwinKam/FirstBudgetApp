import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var items: FetchedResults<TransactionItem>
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: NewTransaction()) {
                    Text("Click me to add new transaction")
                        .frame(width: 200, height: 40, alignment: .center)
                        .background(Color.green)
                        .cornerRadius(10)
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

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
