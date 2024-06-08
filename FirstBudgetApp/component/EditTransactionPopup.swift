import SwiftUI

struct EditTransactionPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authState: AuthState
    var transaction: TransactionItem

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all) // Ensures the entire sheet background adapts to dark mode

            VStack(spacing: 16) {
                Text("Edit Transaction")
                    .font(.headline)
                    .foregroundColor(Color(.label)) // Adapts to dark mode
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Description: \(transaction.transactionDescription)")
                        .foregroundColor(Color(.label)) // Adapts to dark mode
                    Text("Amount: \(transaction.amount, specifier: "%.2f")")
                        .foregroundColor(Color(.label)) // Adapts to dark mode
                    Text("Category: \(transaction.category?.name ?? "No Category")")
                        .foregroundColor(Color(.label)) // Adapts to dark mode
                }
                .padding()

                HStack {
                    Button(action: deleteTransaction) {
                        Text("Delete")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Close")
                            .padding()
                            .background(Color(.systemGray)) // Adapts to dark mode
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.horizontal, 20)
        }
    }

    private func deleteTransaction() {
        withAnimation {
            do {
                try TransactionManager.shared.deleteTransaction(transaction: transaction, authState: authState)
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                print("cant delete transaction error \(nsError), \(nsError.userInfo)")
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
