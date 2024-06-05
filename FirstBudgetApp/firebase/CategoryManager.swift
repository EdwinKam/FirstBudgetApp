//
//  CategoryManager.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 6/3/24.
//

import Foundation
import FirebaseFirestore
import CoreData

struct TransactionDbCategory {
    var id: String // Category ID
    var name: String
    // Add other fields as necessary
}

class CategoryManager {
    
    static let shared = CategoryManager()
    
    private let db = Firestore.firestore()
    
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    // MARK: - public function
    func addCatgory(name: String) -> TransactionCategory{
        let newCategory = addCategoryToCoreData(name: name)
        // async task to add to firebase
        Task {
            do {
                try await self.addNewCategoryToFirebase(category: newCategory)
            } catch {
                let nsError = error as NSError
                print("Error adding category to Firebase: \(nsError), \(nsError.userInfo)")
            }
        }
        return newCategory
    }
    
    func fetchCategories() async throws -> [TransactionCategory] {
        return try await fetchCategoriesFromFirebase()
    }
    
    func deleteCategory(category: TransactionCategory) {
        do {
            // Call the async function without waiting for it
            Task {
                do {
                    try await self.deleteCategoryFromFirebase(category: category)
                    print("successfully delete from firebase")
                } catch {
                    let nsError = error as NSError
                    print("Error deleting category from Firebase: \(nsError), \(nsError.userInfo)")
                }
            }
            try deleteFromCoreData(category: category)
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    // this func gets call when the app is boot, code in FirstBudgetApp.swift
    func downloadCategories() async throws {
//        print("syncing data from firebase")
//        
//        // Extract categories from Firestore
//        let firestoreCategories: [TransactionCategory] = try await fetchCategoriesFromFirebase()
//        
//        // Replace everything in Core Data
//        let viewContext = coreDataManager.viewContext
//        let coreDataCategories = try fetchFromCoreData()
//        
//        // Delete existing categories
//        print("deleting")
//        CoreDataManager.shared.deleteAllPersistentStores()
////        print(coreDataCategories.map { $0.name })
////        for category in coreDataCategories {
////            viewContext.delete(category)
////        }
//        
//        // Add new categories from Firestore
//        print("inserting")
//        print(firestoreCategories.map { $0.name })
//        for category in firestoreCategories {
//            viewContext.insert(category)
//        }
//        
//        // Save context
////        do {
//                    try viewContext.save()
////                } catch {
////                    let nsError = error as NSError
////                    print("An error occurred while saving: \(nsError), \(nsError.userInfo)")
////                    throw error
////                }
    }
    
    // MARK: - Category Management
    
    private func addNewCategoryToFirebase(category: TransactionCategory) async throws {
        let auth = try AuthManager.shared.getAuthenticatedUser()
        let categoryData: [String: Any] = [
            "id": category.id.uuidString,
            "name": category.name ?? ""
        ]
        
        // Reference to the user's categories collection
        let userCategoriesRef = db.collection("users").document(auth.uid).collection("categories")
        
        // Add the new category document under user
        try await userCategoriesRef.document(category.id.uuidString).setData(categoryData)
    }
    
    private func fetchCategoriesFromFirebase() async throws -> [TransactionCategory] {
        let auth = try AuthManager.shared.getAuthenticatedUser()
        // Fetch from Firestore
        let snapshot = try await db.collection("users").document(auth.uid).collection("categories").getDocuments()
        
        let firestoreCategories: [TransactionCategory] = try snapshot.documents.compactMap { document in
            let data = document.data()
            
            guard let idString = data["id"] as? String,
                  let name = data["name"] as? String,
                  let id = UUID(uuidString: idString) else {
                throw NSError(domain: "CategoryManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode category data"])
            }
            
            let category = TransactionCategory(context: coreDataManager.viewContext)
            category.id = id
            category.name = name
            return category
        }
        print("firebase category")
        print(firestoreCategories.map { $0.name })
        return firestoreCategories
    }
    
    private func deleteCategoryFromFirebase(category: TransactionCategory) async throws {
        let auth = try AuthManager.shared.getAuthenticatedUser()
        
        // Reference to the user's categories collection
        let userCategoriesRef = db.collection("users").document(auth.uid).collection("categories")
        
        // Delete the category document under user
        try await userCategoriesRef.document(category.id.uuidString).delete()
    }
    
    // MARK: -function to get from local core data
    
    private func addCategoryToCoreData(name: String) -> TransactionCategory {
        let viewContext = coreDataManager.viewContext
        let newCategoryItem = TransactionCategory(context: viewContext)
        newCategoryItem.name = name
        newCategoryItem.id = UUID()
        let newCategory = newCategoryItem
        do {
            try viewContext.save()
            return newCategory
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func fetchFromCoreData() throws -> [TransactionCategory] {
        let viewContext = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            throw error
        }
    }
    
    func updateCategoryFromCoreData(category: TransactionCategory, name: String) -> TransactionCategory {
        let viewContext = coreDataManager.viewContext
        category.name = name
        do {
            try viewContext.save()
            return category
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteFromCoreData(category: TransactionCategory) throws {
        let context = coreDataManager.viewContext
        context.delete(category)
        
        try context.save()
    }
}
