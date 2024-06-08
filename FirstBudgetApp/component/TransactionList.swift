import SwiftUI

struct TransactionList: View {
    @Environment(\.managedObjectContext) private var viewContext
    var items: [TransactionItem]
    var filteredByCategory: TransactionCategory?
    @State private var selectedItem: TransactionItem?

    // Date formatter to format the date
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium // You can customize the date style as needed
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(filteredItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(item.transactionDescription)")
                                if let date = item.createdAt {
                                    Text(dateFormatter.string(from: date))
                                        .foregroundColor(.secondary)
                                        .font(.subheadline)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(item.amount, specifier: "%.2f")")
                                Text("\(item.category?.name ?? "No Category")")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        }
                        .padding() // Add padding inside each item
                        .background(
                            RoundedRectangle(cornerRadius: 30)
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
        let filtered: [TransactionItem]
        if let category = filteredByCategory {
            filtered = items.filter { $0.category?.id == category.id }
        } else {
            filtered = Array(items)
        }
        return filtered.sorted {
            let date1 = $0.createdAt ?? Date()
            let date2 = $1.createdAt ?? Date()
            return date1 > date2
        }
    }
}

#Preview {
    // Provide a mock TransactionItem for preview purposes
    let context = PersistenceController.preview.container.viewContext
    let transaction = TransactionItem(context: context)
    transaction.transactionDescription = "Sample Transaction"
    transaction.amount = 100.0
    transaction.category = TransactionCategory(context: context)
    transaction.category?.name = "Sample Category"
    transaction.createdAt = Date()

    return TransactionList(items: [transaction], filteredByCategory: nil)
        .environment(\.managedObjectContext, context)
}
