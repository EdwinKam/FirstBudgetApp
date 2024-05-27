import SwiftUI
import CoreData

struct NewTransaction: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var categories: FetchedResults<TransactionCategory>

    @State private var transactionDescription: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: TransactionCategory?
    @State private var isPresentingCategoryPopup: Bool = false
    @State private var newCategoryName: String = ""

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

                        Text("Select Category")
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 16) {
                            ForEach(categories) { category in
                                CategoryCircleView(category: category, isSelected: category == selectedCategory)
                                    .onTapGesture {
                                        selectedCategory = category
                                    }
                            }
                            PlusCircleView(isSelected: false)
                                .onTapGesture {
                                    isPresentingCategoryPopup = true
                                }
                        }
                        .padding(.vertical)

                        Button(action: addItem) {
                            Text("Submit")
                                .padding()
                                .background(transactionDescription.isEmpty || amount.isEmpty || selectedCategory == nil ? Color.gray : Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(transactionDescription.isEmpty || amount.isEmpty || selectedCategory == nil)
                    }
                }
                .padding()
                .sheet(isPresented: $isPresentingCategoryPopup) {
                    NewCategoryPopup(isPresented: $isPresentingCategoryPopup, newCategoryName: $newCategoryName) {
                        addCategory(name: newCategoryName)
                    }
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.white)
                    .presentationCornerRadius(30)
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

    private func addCategory(name: String) {
        let newCategory = TransactionCategory(context: viewContext)
        newCategory.name = name
        newCategory.id = UUID()
        do {
            try viewContext.save()
            selectedCategory = newCategory  // Select the newly added category
            print("Category added successfully")
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


struct CategoryCircleView: View {
    var category: TransactionCategory
    var isSelected: Bool

    var body: some View {
        VStack {
            let firstLetter = category.name?.prefix(1) ?? "?"
            Text(String(firstLetter))
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                )
            Text(category.name ?? "")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
    }
}

struct PlusCircleView: View {
    var isSelected: Bool

    var body: some View {
        VStack {
            Text("+")
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(isSelected ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                )
            Text("Add")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    NewTransaction().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
