//
//  ContentView.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/26/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // i think this fails if persistent.swift does not have sample data
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var items: FetchedResults<TransactionItem>
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: NewTransaction()) {
                    Text("Click me to add new transaction")
                        .frame(width: 40, height: 40, alignment: .center)
                        .background(Color.green)
                        .cornerRadius(100)
                }
                List {
                    ForEach(items) { item in
                        NavigationLink(destination: Text("\(item.transactionDescription ?? "No Description") - \(item.amount, specifier: "%.2f")")) {
                            Text("\(item.transactionDescription ?? "No Description") - \(item.amount, specifier: "%.2f")")
                        }
                    }
                }
            }
        }
    }
}
        
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
    
