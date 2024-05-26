//
//  NewTransaction.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/26/24.
//

import SwiftUI
import CoreData

struct NewTransaction: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

        @State private var transactionDescription: String = ""
        @State private var amount: String = ""

        var body: some View {
            NavigationView {
                VStack {
                    Form {
                        Section(header: Text("New Transaction")) {
                            TextField("Description", text: $transactionDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            TextField("Amount", text: $amount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button(action: addItem) {
                                Text("Submit")
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    
                }}}

    private func addItem() {
            guard let amountValue = Double(amount), !transactionDescription.isEmpty else { return }

            withAnimation {
                let newItem = TransactionItem(context: viewContext)
                newItem.transactionDescription = transactionDescription
                newItem.amount = amountValue

                do {
                    try viewContext.save()
                    transactionDescription = ""  // Clear the input fields after saving
                    amount = ""
                    print("Item added successfully")
                    presentationMode.wrappedValue.dismiss()  // Dismiss the view and go back to ContentView
                } catch {
                    let nsError = error as NSError
                    print("Unresolved error \(nsError), \(nsError.userInfo)")
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    NewTransaction().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

