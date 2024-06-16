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
    
    private var categoryCache: [String: TransactionCategory] = [:]
    
    private init() {}
    
    // MARK: - public function
    func addCatgory(name: String, authState: AuthState) -> TransactionCategory {
        let newCategory = addCategoryToCoreData(name: name)
        print("adding category \(name)")
        // async task to add to firebase
        Task {
            do {
                try await self.addNewCategoryToFirebase(category: newCategory, authState: authState)
            } catch {
                let nsError = error as NSError
                print("Error adding category to Firebase: \(nsError), \(nsError.userInfo)")
            }
        }
        return newCategory
    }
    
    func addCatgoryAsync(name: String, authState: AuthState) async throws -> TransactionCategory {
        let newCategory = addCategoryToCoreData(name: name)
        print("adding category async \(name)")
        // async task to add to firebase
        try await self.addNewCategoryToFirebase(category: newCategory, authState: authState)
        return newCategory
    }
    
    func fetchCategories(authState: AuthState) async throws -> [TransactionCategory] {
        return try await fetchCategoriesFromFirebase(authState: authState)
    }
    
    func fetchCategoryById(categoryId: String, authState: AuthState) async throws -> TransactionCategory? {
        return try await fetchCategoryByIdFromFirebase(categoryId: categoryId, authState: authState)
    }
    
    func updateCategory(category: TransactionCategory, name: String, authState: AuthState) -> TransactionCategory {
        let newCategory = updateCategoryFromCoreData(category: category, name: name)
        Task {
            do {
                try await self.addNewCategoryToFirebase(category: newCategory, authState: authState)
            } catch {
                let nsError = error as NSError
                print("Error adding category to Firebase: \(nsError), \(nsError.userInfo)")
            }
        }
        return newCategory
    }
    
    func deleteCategory(category: TransactionCategory, authState: AuthState) {
        do {
            // Call the async function without waiting for it
            Task {
                do {
                    try await self.deleteCategoryFromFirebase(category: category, authState: authState)
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
    func downloadCategories(authState: AuthState) async throws {
        // Your existing downloadCategories implementation
    }
    
    // MARK: - Category Management
    
    func addNewCategoryToFirebase(category: TransactionCategory, authState: AuthState) async throws {
        guard let auth = authState.authUser else {
            throw URLError(.badServerResponse)
        }
        
        let categoryData: [String: Any] = [
            "id": category.id.uuidString,
            "name": category.name
        ]
        
        // Reference to the user's categories collection
        let userCategoriesRef = db.collection("users").document(auth.uid).collection("categories")
        
        // Add the new category document under user
        try await userCategoriesRef.document(category.id.uuidString).setData(categoryData)
    }

    private func fetchCategoryByIdFromFirebase(categoryId: String, authState: AuthState) async throws -> TransactionCategory? {
        guard let auth = authState.authUser else {
            throw URLError(.badServerResponse)
        }

        let db = Firestore.firestore()

        // Fetch the category document from Firestore
        let document = try await db.collection("users").document(auth.uid).collection("categories").document(categoryId).getDocument()
        
        guard let data = document.data() else {
            print("Category not found")
            return nil
        }

        guard let idString = data["id"] as? String,
              let name = data["name"] as? String,
              let id = UUID(uuidString: idString) else {
            throw NSError(domain: "CategoryManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode category data"])
        }

        let category = TransactionCategory(context: coreDataManager.viewContext)
        category.id = id
        category.name = name

        print("Fetched category from Firebase: \(category.name)")

        return category
    }
    
    private func fetchCategoriesFromFirebase(authState: AuthState) async throws -> [TransactionCategory] {
        guard let auth = authState.authUser else {
            throw URLError(.badServerResponse)
        }

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
    
    private func deleteCategoryFromFirebase(category: TransactionCategory, authState: AuthState) async throws {
        guard let auth = authState.authUser else {
            throw URLError(.badServerResponse)
        }
        
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
