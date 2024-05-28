import SwiftUI

struct EditTransactionPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
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
                presentationMode.wrappedValue.dismiss()
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
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
