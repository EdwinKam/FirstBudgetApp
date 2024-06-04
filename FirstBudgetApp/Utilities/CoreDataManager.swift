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
}
