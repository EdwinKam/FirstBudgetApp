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
    
    // MARK: - Category Management
    
    func createNewCategory(auth: AuthDataResultModel, name: String) {
        let categoryId = UUID().uuidString
        let categoryData: [String: Any] = [
            "id": categoryId,
            "name": name
        ]
        
        // Reference to the user's categories collection
        let userCategoriesRef = db.collection("users").document(auth.uid).collection("categories")
        
        // Add the new category document under user
        userCategoriesRef.document(categoryId).setData(categoryData) { error in
            if let error = error {
                print("Error adding category: \(error.localizedDescription)")
            } else {
                print("Category successfully added!")
            }
        }
    }
    
    func fetchCategories(auth: AuthDataResultModel) async throws -> [TransactionDbCategory] {
        // Reference to the user's categories collection
        let snapshot = try await db.collection("users").document(auth.uid).collection("categories").getDocuments()
        
        let categories: [TransactionDbCategory] = snapshot.documents.compactMap { document in
            let data = document.data()
            
            let id = data["id"] as? String
            let name = data["name"] as? String
            
            guard let id = id, let name = name else {
                return nil
            }
            
            return TransactionDbCategory(
                id: id,
                name: name
            )
        }
        
        return categories
    }
    
    func deleteCategory(auth: AuthDataResultModel, categoryId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Reference to the user's categories collection
        let userCategoriesRef = db.collection("users").document(auth.uid).collection("categories")
        
        userCategoriesRef.document(categoryId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func fetchFromCoreData() throws -> [TransactionCategory] {
        let viewContext = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<TransactionCategory> = TransactionCategory.fetchRequest()

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            throw error
        }
    }
    
    func addCategoryToCoreData(name: String) -> TransactionCategory {
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
    
    func deleteFromCoreData(category: TransactionCategory) throws {
        let context = coreDataManager.viewContext
        context.delete(category)
        
        try context.save()
    }
}
