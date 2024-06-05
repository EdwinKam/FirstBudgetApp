//
//  CoreDataManager.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/26/24.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let persistenceController = PersistenceController.shared
    
    private init() {}
    
    var viewContext: NSManagedObjectContext {
        return persistenceController.container.viewContext
    }
    
    func deleteAllPersistentStores() {
        guard let persistentStoreCoordinator = viewContext.persistentStoreCoordinator else { return }

        for store in persistentStoreCoordinator.persistentStores {
            guard let storeURL = store.url else { continue }

            do {
                try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: store.type, options: nil)
                try persistentStoreCoordinator.addPersistentStore(ofType: store.type, configurationName: nil, at: storeURL, options: nil)
            } catch {
                print("Failed to clear persistent store: \(error)")
            }
        }
    }
}
