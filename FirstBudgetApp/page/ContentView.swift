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
    @State private var showOptions = false // State to toggle the options

    // Computed property to get the top 2 popular categories
    private var top2Categories: [TransactionCategory] {
        let categoryCounts = Dictionary(grouping: items, by: { $0.category })
            .mapValues { $0.count }
            .sorted(by: { $0.value > $1.value })
            .prefix(2)
            .compactMap { $0.key }
        return categoryCounts
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                // Main content
                VStack {
                    if !items.isEmpty {
                        PieChartView(transactionItems: Array(items), selectedCategory: $selectedCategory)
                            .frame(height: 300)
                            .padding()
                        TransactionList(items: items, filteredByCategory: selectedCategory)
                            .background(Color.white) // Ensure the TransactionList has a white background
                            .cornerRadius(40) // Optional: add corner radius to the transaction list
                    } else {
                        Text("No data to display")
                            .frame(height: 300)
                            .padding()
                    }
                }
                .blur(radius: showOptions ? 3 : 0) // Apply blur effect based on showOptions state
                
                // Overlay to capture tap gesture and close options
                if showOptions {
                    Color.clear
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                showOptions = false
                            }
                        }
                }

                // Options menu
                VStack {
                    // The circular button
                    Button(action: {
                        withAnimation {
                            showOptions.toggle()
                        }
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Color(.systemGreen).opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    // The pop-up options
                    if showOptions {
                        VStack(alignment: .leading, spacing: 10) {
                            NavigationLink(destination: NewTransaction()) {
                                Text("Add New Transaction")
                                    .frame(width: 120, height: 40)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            ForEach(top2Categories, id: \.self) { category in
                                NavigationLink(destination: NewTransaction(selectedCategory: category)) {
                                    Text(category.name ?? "Unknown")
                                        .frame(width: 120, height: 40)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .transition(AnyTransition.scale(scale: 0.5).combined(with: .opacity))
                    }
                }
                .padding()
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
