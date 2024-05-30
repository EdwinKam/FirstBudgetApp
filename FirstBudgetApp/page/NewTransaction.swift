import SwiftUI
import CoreData

struct NewTransaction: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var transactionDescription: String = ""
    @State private var amount: String = "$0.00"
    @State private var rawAmount: String = ""
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
                        .font(.largeTitle)
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
                            .disabled(transactionDescription.isEmpty)
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

                        CustomAmountTextField(
                            amount: $amount,
                            rawAmount: $rawAmount
                        )
                        .font(.largeTitle)
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
                                    .foregroundColor(transactionDescription.isEmpty || rawAmount.isEmpty || selectedCategory == nil ? .gray : .green)
                            }
                            .disabled(transactionDescription.isEmpty || rawAmount.isEmpty || selectedCategory == nil)
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
        // Safely unwrap the rawAmount and convert it to a Double, then divide by 100
        guard let rawAmountValue = Double(rawAmount),
              !transactionDescription.isEmpty,
              let category = selectedCategory else {
            return
        }
        
        let amountValue = rawAmountValue / 100.0

        withAnimation {
            // Create a new transaction item in the Core Data context
            let newItem = TransactionItem(context: viewContext)
            newItem.transactionDescription = transactionDescription
            newItem.amount = amountValue
            newItem.category = category

            do {
                // Try to save the context
                try viewContext.save()
                // Clear the input fields after saving
                transactionDescription = ""
                amount = "$0.00"
                rawAmount = ""
                selectedCategory = nil
                // Print success message and dismiss the view
                print("Item added successfully")
                presentationMode.wrappedValue.dismiss()
            } catch {
                // Handle any errors during saving
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

    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .padding(.leading, 8)
            }
            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
                .font(.largeTitle)
                .padding(8)
                .background(Color.clear)
                .focused($isFocused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isFocused = true
                    }
                }
        }
    }
}

struct CustomAmountTextField: View {
    @Binding var amount: String
    @Binding var rawAmount: String
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Text(amount)
                .font(.largeTitle)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.clear)

            TextField("", text: Binding(
                get: { self.rawAmount },
                set: { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != self.rawAmount {
                        self.rawAmount = filtered
                    }
                    if let intValue = Int(self.rawAmount) {
                        self.amount = "$\(String(format: "%.2f", Double(intValue) / 100.0))"
                    } else {
                        self.amount = "$0.00"
                    }
                }
            ))
            .font(.largeTitle)
            .foregroundColor(.clear) // Make the text field itself invisible
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isFocused = true
                }
            }
        }
    }
}

// Assuming SelectCategoryView and TransactionCategory are defined elsewhere

#Preview {
    NewTransaction().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
