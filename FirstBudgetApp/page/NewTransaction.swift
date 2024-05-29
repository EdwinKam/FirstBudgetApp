import SwiftUI
import CoreData

struct NewTransaction: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var transactionDescription: String = ""
    @State private var amount: String = ""
    @State var selectedCategory: TransactionCategory?
    @State private var isPresentingCategoryPopup: Bool = false
    @State private var newCategoryName: String = ""
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

                        TextField("Enter Description", text: $transactionDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
                            .padding(.top, 20)
                            .padding(.leading, 20)

                            Spacer()
                        }

                        Text("How much was it?")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 20)
                            .padding(.leading, 20)

                        TextField("Enter Amount", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.bottom, 20)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)

                        SelectCategoryView(
                            selectedCategory: $selectedCategory,
                            isPresentingCategoryPopup: $isPresentingCategoryPopup
                        )
                        .sheet(isPresented: $isPresentingCategoryPopup) {
                            NewCategoryPopup(isPresented: $isPresentingCategoryPopup, newCategoryName: $newCategoryName) {
                                addCategory(name: newCategoryName)
                            }
                            .presentationDetents([.medium])
                            .presentationDragIndicator(.visible)
                            .presentationBackground(Color.white)
                            .presentationCornerRadius(30)
                        }

                        Spacer()

                        HStack {
                            Spacer()
                            Button(action: addItem) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(transactionDescription.isEmpty || amount.isEmpty || selectedCategory == nil ? .gray : .green)
                            }
                            .disabled(transactionDescription.isEmpty || amount.isEmpty || selectedCategory == nil)
                            .padding(20)
                        }
                    }
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
