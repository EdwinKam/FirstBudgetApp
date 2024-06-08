import SwiftUI
import CoreData

struct NewTransaction: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @EnvironmentObject var authState: AuthState
    @State private var transactionDescription: String = ""
    @State private var amount: String = ""
    @State var selectedCategory: TransactionCategory?
    @State private var isPresentingCategoryPopup: Bool = false
    @State private var showDetails: Bool = false
    @FocusState private var isDescriptionFieldFocused: Bool
    @FocusState private var isAmountFieldFocused: Bool

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    Color.clear // This makes the whole area tappable

                    if !showDetails {
                        VStack(alignment: .leading) {
                            Text("What's the new transaction for?")
                                .font(.largeTitle)
                                .bold()
                                .padding(.bottom, 20)

                            TextField("Enter Description", text: $transactionDescription)
                                .font(.largeTitle)
                                .padding(.bottom, 20)
                                .background(Color.clear)
                                .focused($isDescriptionFieldFocused)

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
                        .navigationTitle("New Transaction")
                    } else {
                        VStack(alignment: .leading) {
                            Text("How much was it?")
                                .font(.largeTitle)
                                .bold()
                                .padding(.bottom, 20)
                                .padding(.leading, 20)

                            TextField("Enter Amount", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.largeTitle)
                                .padding(.bottom, 20)
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                                .focused($isAmountFieldFocused)

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

                                Button(action: {
                                    Task {
                                        addItem()
                                    }
                                }) {
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
                .frame(width: geometry.size.width, height: geometry.size.height)
                .contentShape(Rectangle()) // Make the entire area tappable
                .onTapGesture {
                    if !showDetails {
                        self.isDescriptionFieldFocused = true
                    } else {
                        self.isAmountFieldFocused = true
                    }
                }
            }
        }
    }

    private func addItem() {
        print("trying to add transaction in NewTransaction")
        guard let amountValue = Double(amount),
              !transactionDescription.isEmpty,
              let category = selectedCategory else {
            return
        }
        do {
            try TransactionManager.shared.saveTransaction(description: transactionDescription, amount: amountValue, category: category, authState: authState)
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

#Preview {
    NewTransaction().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
