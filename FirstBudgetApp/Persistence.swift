//
//  Persistence.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/26/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let defaultCategories = ["work", "home", "electric", "hobby"]
        var categories = [TransactionCategory]()
        
        for categoryName in defaultCategories {
            let newCategory = TransactionCategory(context: viewContext)
            newCategory.id = UUID()
            newCategory.name = categoryName
            categories.append(newCategory)
        }

        // Associate each TransactionItem with a valid category
        for i in 0..<10 {
            let newItem = TransactionItem(context: viewContext)
            newItem.transactionDescription = "sample description \(i)"
            newItem.amount = 90
            newItem.createdAt = initializeDate(from: "06/02/2024")
            if let category = categories.randomElement() {
                newItem.category = category
            }
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FirstBudgetApp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static func initializeDate(from string: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let date = dateFormatter.date(from: string)
            return date
        }
}
