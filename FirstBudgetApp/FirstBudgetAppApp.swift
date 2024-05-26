//
//  FirstBudgetAppApp.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/26/24.
//

import SwiftUI

@main
struct FirstBudgetAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
