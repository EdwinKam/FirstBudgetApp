import SwiftUI
import CoreData

struct NewCategoryPopup: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    @Binding var newCategory: TransactionCategory?
    @State private var newCategoryName: String = ""
    @Binding var editFromCategory: TransactionCategory?
    @EnvironmentObject var authState: AuthState

    var body: some View {
        VStack {
            Text(editFromCategory == nil ? "New Category" : "Edit Category")
                .font(.headline)
                .padding()

            TextField("Category Name", text: $newCategoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onAppear {
                    if let category = editFromCategory {
                        newCategoryName = category.name
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
                
                if editFromCategory != nil {
                    Button(action: {
                        deleteCategory(category: editFromCategory!)
                        isPresented = false
                    }) {
                        Text("Delete")
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .padding()
    }

    private func addCategory(name: String) {
        newCategory = CategoryManager.shared.addCatgory(name: name, authState: authState)
    }

    private func updateCategory(category: TransactionCategory, name: String) {
        newCategory = CategoryManager.shared.updateCategory(category: category, name: name, authState: authState)
    }

    private func deleteCategory(category: TransactionCategory) {
        do {
            try CategoryManager.shared.deleteCategory(category: category, authState: authState)
        } catch {
            print("Failed to delete category: \(error.localizedDescription)")
        }
    }
}
