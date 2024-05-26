//
//  ContentView.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/26/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: NewTransaction()) {
                    Text("click me to add new transaction").frame(width: 300, height: 300, alignment: .center).background(Color.green).cornerRadius(100)
                }
            }
        }
    }
}
        
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
    
