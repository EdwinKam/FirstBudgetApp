import SwiftUI
import CoreData

struct NewCategoryPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @Binding var newCategory: TransactionCategory?
    @State private var newCategoryName: String = ""
    @Binding var editFromCategory: TransactionCategory?

    var body: some View {
        VStack {
            Text(editFromCategory == nil ? "New Category" : "Edit Category")
                .font(.headline)
                .padding()

            TextField("Category Name", text: $newCategoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    print(editFromCategory)
                    if let category = editFromCategory {
                        newCategoryName = category.name ?? ""
                    }
                }

            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    if let category = editFromCategory {
                        updateCategory(category: category, name: newCategoryName)
                    } else {
                        addCategory(name: newCategoryName)
                    }
                    isPresented = false
                }) {
                    Text("Save")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(newCategoryName.isEmpty)
            }
            .padding()
        }
        .padding()
    }

    private func addCategory(name: String) {
        let newCategoryItem = TransactionCategory(context: viewContext)
        newCategoryItem.name = name
        newCategoryItem.id = UUID()
        newCategory = newCategoryItem
        do {
            try viewContext.save()
            print("Category added successfully")
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func updateCategory(category: TransactionCategory, name: String) {
        category.name = name
        do {
            try viewContext.save()
            newCategory = category
            print("Category updated successfully")
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
