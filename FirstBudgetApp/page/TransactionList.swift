//
//  TransactionList.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/27/24.
//

import SwiftUI

struct TransactionList: View {
    @Environment(\.managedObjectContext) private var viewContext
    var items: FetchedResults<TransactionItem>
    var filteredByCategory: TransactionCategory?
    @State private var selectedItem: TransactionItem?
    @State private var showEditPopup: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredItems) { item in
                    HStack {
                        Text("\(item.transactionDescription ?? "No Description")")
                        Spacer()
                        Text("\(item.amount, specifier: "%.2f")")
                        Spacer()
                        Text("\(item.category?.name ?? "No Category")")
                    }
                    .contentShape(Rectangle()) // Makes the entire HStack tappable
                    .onTapGesture {
                        selectedItem = item
                        showEditPopup = true
                    }
                }
            }
        }
        .sheet(isPresented: $showEditPopup, onDismiss: {
            selectedItem = nil
        }) {
            if let selectedItem = selectedItem {
                EditTransactionPopup(isPresented: $showEditPopup, transaction: selectedItem)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(Color.white)
                    .presentationCornerRadius(30) // Apply rounded corners directly to the sheet
            }
        }
    }
    
    private var filteredItems: [TransactionItem] {
        if let category = filteredByCategory {
            return items.filter { $0.category?.id == category.id }
        } else {
            return Array(items)
        }
    }
}
