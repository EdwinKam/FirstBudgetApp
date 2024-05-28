import SwiftUI

struct TransactionList: View {
    @Environment(\.managedObjectContext) private var viewContext
    var items: FetchedResults<TransactionItem>
    var filteredByCategory: TransactionCategory?
    @State private var selectedItem: TransactionItem?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
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
                        .padding() // Add padding inside each item
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(Color(.systemGreen).opacity(0.2)) // Light green background
                                .shadow(radius: 3)
                        )
                        .contentShape(Rectangle()) // Makes the entire HStack tappable
                        .onTapGesture {
                            selectedItem = item
                        }
                        .padding(.horizontal) // Add horizontal padding for better appearance
                    }
                }
                .padding(.top) // Add top padding to the list
            }
            .background(Color.clear) // Ensure the background is clear to show the underlying color
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
