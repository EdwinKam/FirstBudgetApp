import SwiftUI

struct TransactionList: View {
    @Environment(\.managedObjectContext) private var viewContext
    var items: FetchedResults<TransactionItem>
    var filteredByCategory: TransactionCategory?
    @State private var selectedItem: TransactionItem?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredItems) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(item.transactionDescription ?? "No Description")")
                            Text("\(item.category?.name ?? "No Category")")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        Spacer()
                        Text("\(item.amount, specifier: "%.2f")")
                            .alignmentGuide(.trailing) { d in d[.trailing] }
                    }
                    .contentShape(Rectangle()) // Makes the entire HStack tappable
                    .onTapGesture {
                        selectedItem = item
                    }
                }
            }
        }
        .sheet(item: $selectedItem, onDismiss: {
            selectedItem = nil
        }) { selectedItem in
            EditTransactionPopup(transaction: selectedItem)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color.white)
                .presentationCornerRadius(30) // Apply rounded corners directly to the sheet
        }
    }
    
    private var filteredItems: [TransactionItem] {
        if let category = filteredByCategory {
            return items.filter { $0.category?.id == category.id }
        } else {
            return Array(items)
        }
    }
}
