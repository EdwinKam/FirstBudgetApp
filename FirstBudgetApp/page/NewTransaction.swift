import SwiftUI
import CoreData

struct NewTransaction: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var transactionDescription: String = ""
    @State private var amount: String = ""
    @State var selectedCategory: TransactionCategory?
    @State private var isPresentingCategoryPopup: Bool = false
    @State private var showDetails: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                if !showDetails {
                    VStack(alignment: .leading) {
                        Text("What's the new transaction for?")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 20)

                        CustomTextField(
                            placeholder: Text("Enter Description").foregroundColor(.gray),
                            text: $transactionDescription
                        )
                        .font(.largeTitle) // Make the input text even bigger
                        .padding(.bottom, 20)

                        HStack {
                            Spacer()
                            Button(action: {
                                if !transactionDescription.isEmpty {
                                    withAnimation(.easeInOut) {
                                        showDetails = true
                                    }
                                }
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(transactionDescription.isEmpty ? .gray : .blue)
                            }
                            .padding()
                            .disabled(transactionDescription.isEmpty) // Disable button when description is empty
                        }
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .leading))
                } else {
                    VStack(alignment: .leading) {
                        Text("How much was it?")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 20)
                            .padding(.leading, 20)

                        CustomTextFieldWithPrefix(
                            prefix: "$",
                            placeholder: Text("Enter Amount").foregroundColor(.gray),
                            text: $amount
                        )
                        .font(.largeTitle) // Make the input text even bigger
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)

                        Text("What category is it?")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 20)
                            .padding(.leading, 20)
                        
                        SelectCategoryView(
                            selectedCategory: $selectedCategory,
                            isPresentingCategoryPopup: $isPresentingCategoryPopup
                        )
                        .padding(.bottom, 20)

                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    showDetails = false
                                }
                            }) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.blue)
                            }
                            .padding()

                            Spacer()

                            Button(action: addItem) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(transactionDescription.isEmpty || amount.isEmpty || selectedCategory == nil ? .gray : .green)
                            }
                            .disabled(transactionDescription.isEmpty || amount.isEmpty || selectedCategory == nil)
                            .padding()
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .trailing))
                }
            }
            .navigationTitle("New Transaction")
        }
    }

    private func addItem() {
        guard let amountValue = Double(amount),
              !transactionDescription.isEmpty,
              let category = selectedCategory else {
            return
        }

        withAnimation {
            let newItem = TransactionItem(context: viewContext)
            newItem.transactionDescription = transactionDescription
            newItem.amount = amountValue
            newItem.category = category

            do {
                try viewContext.save()
                transactionDescription = ""  // Clear the input fields after saving
                amount = ""
                selectedCategory = nil
                print("Item added successfully")
                presentationMode.wrappedValue.dismiss()  // Dismiss the view and go back to ContentView
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool) -> () = { _ in }
    var commit: () -> () = { }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                .font(.largeTitle) // Make the input text even bigger
                .padding()
                .background(Color.clear)
        }
    }
}

struct CustomTextFieldWithPrefix: View {
    var prefix: String
    var placeholder: Text
    @Binding var text: String
    var editingChanged: (Bool) -> () = { _ in }
    var commit: () -> () = { }

    var body: some View {
        HStack {
            Text(prefix)
                .font(.largeTitle) // Make the prefix text bigger
                .foregroundColor(.gray)
            ZStack(alignment: .leading) {
                if text.isEmpty { placeholder }
                TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                    .font(.largeTitle) // Make the input text even bigger
                    .padding()
                    .background(Color.clear)
                    .keyboardType(.decimalPad) // Ensure the keyboard is decimal pad
            }
        }
    }
}

#Preview {
    NewTransaction().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
