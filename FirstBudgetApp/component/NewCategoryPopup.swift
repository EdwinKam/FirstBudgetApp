//
//  NewCategoryPopup.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/27/24.
//

import SwiftUI

struct NewCategoryPopup: View {
    @Binding var isPresented: Bool
    @Binding var newCategoryName: String
    var onSave: () -> Void

    var body: some View {
        VStack {
            Text("New Category")
                .font(.headline)
                .padding()

            TextField("Category Name", text: $newCategoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

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
                    onSave()
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
}

//#Preview {
//    NewCategoryPopup().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
