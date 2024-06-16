import SwiftUI
import CoreData

struct EditTransactionPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authState: AuthState
    var transaction: TransactionItem

    @State private var isEditing: Bool = false
    @State private var updatedDescription: String
    @State private var updatedAmount: String
    @State private var updatedDate: Date
    @State private var isPresentingDateSheet: Bool = false

    init(transaction: TransactionItem) {
        self.transaction = transaction
        _updatedDescription = State(initialValue: transaction.transactionDescription)
        _updatedAmount = State(initialValue: String(transaction.amount))
        _updatedDate = State(initialValue: transaction.createdAt ?? Date())
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all) // Ensures the entire sheet background adapts to dark mode

            VStack(spacing: 16) {
                HStack {
                    Spacer()

                    Text(isEditing ? "Edit Transaction" : "Transaction Details")
                        .font(.headline)
                        .foregroundColor(Color(.label)) // Adapts to dark mode

                    Spacer()

                    if isEditing {
                        Button(action: {
                            withAnimation {
                                discardChanges()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color(.systemGray))
                                .padding()
                        }
                    } else {
                        Button(action: {
                            withAnimation {
                                isEditing.toggle()
                            }
                        }) {
                            Image(systemName: "pencil")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color(.systemGray))
                                .padding()
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 0) {
                        Text("Description: ")
                            .foregroundColor(Color(.label)) // Adapts to dark mode
                        if isEditing {
                            TextField("", text: $updatedDescription)
                                .highlight(isEnable: true)
                        } else {
                            Text(transaction.transactionDescription)
                                .font(.body)
                                .background(Color.clear)
                        }
                    }

                    HStack(spacing: 0) {
                        Text("Amount: ")
                            .foregroundColor(Color(.label)) // Adapts to dark mode
                        if isEditing {
                            TextField("", text: $updatedAmount)
                                .keyboardType(.decimalPad)
                                .highlight(isEnable: true)
                        } else {
                            Text("\(transaction.amount, specifier: "%.2f")")
                                .font(.body)
                                .background(Color.clear)
                        }
                    }

                    Text("Category: \(transaction.category?.name ?? "No Category")")
                        .foregroundColor(Color(.label)) // Adapts to dark mode

                    HStack(spacing: 0) {
                        Text("Date: ")
                            .foregroundColor(Color(.label)) // Adapts to dark mode
                        if isEditing {
                            Text(isToday(date: updatedDate) ? "Today" : formattedDate(date: updatedDate))
                                .highlight(isEnable: true)
                                .onTapGesture {
                                    isPresentingDateSheet = true
                                }
                                .sheet(isPresented: $isPresentingDateSheet) {
                                    SelectDateView(selectedDate: $updatedDate)
                                        .presentationDragIndicator(.visible)
                                        .onDisappear {
                                            isPresentingDateSheet = false
                                        }
                                }
                                .onChange(of: updatedDate, initial: false) {
                                    isPresentingDateSheet = false
                                }
                        } else {
                            Text(isToday(date: updatedDate) ? "Today" : formattedDate(date: updatedDate))
                                .font(.body)
                                .background(Color.clear)
                        }
                    }
                }
                .padding()

                if isEditing {
                    HStack {
                        Button(action: deleteTransaction) {
                            Image(systemName: "trash")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.red)
                                .padding()
                        }

                        Spacer()

                        Button(action: updateTransaction) {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.green)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                } else {
                    HStack {
                        Spacer()

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
            }
            .padding(.horizontal, 20)
        }
    }

    private func updateTransaction() {
        transaction.transactionDescription = updatedDescription
        if let amount = Double(updatedAmount) {
            transaction.amount = amount
        } else {
            print("Invalid amount entered")
            return
        }
        transaction.createdAt = updatedDate
        do {
            try TransactionManager.shared.updateTranscation(transaction: transaction, authState: authState)
            isEditing = false
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func discardChanges() {
        updatedDescription = transaction.transactionDescription
        updatedAmount = String(transaction.amount)
        updatedDate = transaction.createdAt ?? Date()
        isEditing = false
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

    private func isToday(date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func formattedDate(date: Date?) -> String {
        guard let date = date else {
            return "Unknown Date"
        }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

//#Preview {
//    // Provide a mock TransactionItem for preview purposes
//    let context = PersistenceController.preview.container.viewContext
//    let transaction = TransactionItem(context: context)
//    transaction.transactionDescription = "Sample Transaction"
//    transaction.amount = 100.0
//    transaction.createdAt = nil // Simulate missing createdAt
//    transaction.category = TransactionCategory(context: context)
//    transaction.category?.name = "Sample Category"
//
//    return EditTransactionPopup(transaction: transaction)
//        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
