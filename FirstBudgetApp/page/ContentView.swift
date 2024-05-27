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
                } else {
                    Text("No data to display")
                        .frame(height: 300)
                        .padding()
                }
                List {
                    ForEach(items) { item in
                        HStack {
                            Text("\(item.transactionDescription ?? "No Description")")
                            Spacer()
                            Text("\(item.amount, specifier: "%.2f")")
                            Spacer()
                            Text("\(item.category?.name ?? "No Category")")
                        }
                        .contentShape(Rectangle()) // Makes the entire HStack tappable
                        .onTapGesture {
                            selectedItem = item
                            showEditPopup = true
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .sheet(isPresented: $showEditPopup, onDismiss: {
                selectedItem = nil
            }) {
                if let selectedItem = selectedItem {
                    EditTransactionPopup(isPresented: $showEditPopup, transaction: selectedItem)
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Color.white)
                        .presentationCornerRadius(30) // Apply rounded corners directly to the sheet
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct EditTransactionPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    var transaction: TransactionItem

    var body: some View {
        VStack {
            Text("Edit Transaction")
                .font(.headline)
                .padding()
            
            Text("Description: \(transaction.transactionDescription ?? "No Description")")
            Text("Amount: \(transaction.amount, specifier: "%.2f")")
            Text("Category: \(transaction.category?.name ?? "No Category")")
            
            Button(action: deleteTransaction) {
                Text("Delete")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 16)
            
            Button(action: {
                isPresented = false
            }) {
                Text("Close")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding(30)
    }

    private func deleteTransaction() {
        withAnimation {
            viewContext.delete(transaction)
            do {
                try viewContext.save()
                isPresented = false
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
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
