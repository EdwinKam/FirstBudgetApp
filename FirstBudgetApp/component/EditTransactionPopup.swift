import SwiftUI

struct EditTransactionPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    var transaction: TransactionItem

    var body: some View {
        VStack {
            Text("Edit Transaction")
                .font(.headline)
                .foregroundColor(Color(.label)) // Adapts to dark mode
                .padding()

            VStack(alignment: .leading, spacing: 10) {
                Text("Description: \(transaction.transactionDescription ?? "No Description")")
                    .foregroundColor(Color(.label)) // Adapts to dark mode
                Text("Amount: \(transaction.amount, specifier: "%.2f")")
                    .foregroundColor(Color(.label)) // Adapts to dark mode
                Text("Category: \(transaction.category?.name ?? "No Category")")
                    .foregroundColor(Color(.label)) // Adapts to dark mode
            }
            .padding()

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
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Close")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray)) // Adapts to dark mode
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding(30)
        .background(Color(.systemBackground)) // Adapts to dark mode
        .cornerRadius(12)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all)) // Ensures the entire sheet background adapts to dark mode
    }

    private func deleteTransaction() {
        withAnimation {
            do {
                try TransactionManager.shared.deleteFromCoreData(transaction: transaction)
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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

    return EditTransactionPopup(transaction: transaction)
        .environment(\.managedObjectContext, context)
}
