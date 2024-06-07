//
//  UserManager.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 6/3/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

class TransactionManager {
    static let shared = TransactionManager()
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    // Core Data manager reference
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}
    
    func fetchTransactions() async throws -> [TransactionItem] {
        print("called fetchTransactions")
        return try await fetchTransactionsFromFirebase()
//        return try fetchFromCoreData()
    }
    
    func saveTransaction(description: String, amount: Double, category: TransactionCategory) throws {
        print("trying to save to coredata")
        let transaction = try saveToCoreData(description: description, amount: amount, category: category)
        print("added to coredata")
        Task {
            do {
                try await self.createNewTransactionToFirebase(transaction: transaction)
            } catch {
                let nsError = error as NSError
                print("Error adding transaction to Firebase: \(nsError), \(nsError.userInfo)")
            }
        }
        
    }
    
    func deleteTransaction(transaction: TransactionItem) throws {
        Task {
            do {
                try await self.deleteTransactionFromFirebase(transactionId: transaction.id)
            } catch {
                let nsError = error as NSError
                print("Error adding transaction to Firebase: \(nsError), \(nsError.userInfo)")
            }
        }
        
//        try deleteFromCoreData(transaction: transaction)
    }

    // MARK: - Firestore Transaction Management
    
    func createNewTransactionToFirebase(transaction: TransactionItem) async throws {
        let auth = try AuthManager.shared.getAuthenticatedUser()
        let db = Firestore.firestore()

        // Prepare the data to be saved
        let transactionData: [String: Any] = [
            "id": transaction.id.uuidString,
            "amount": transaction.amount,
            "description": transaction.transactionDescription,
            "createdAt": Timestamp(date: transaction.createdAt ?? Date()),
            "categoryId": transaction.category?.id.uuidString ?? ""
        ]

        // Reference to the user's transactions collection
        let userTransactionsRef = db.collection("users").document(auth.uid).collection("transactions")

        // Add the new transaction document under user
        try await userTransactionsRef.document(transaction.id.uuidString).setData(transactionData)
        
        print("Transaction added successfully to Firebase")
    }
    
    private func fetchTransactionsFromFirebase() async throws -> [TransactionItem] {
        let auth = try AuthManager.shared.getAuthenticatedUser()
        let db = Firestore.firestore()

        // Fetch all documents from the user's transactions collection
        let snapshot = try await db.collection("users").document(auth.uid).collection("transactions").getDocuments()
        
        var transactions: [TransactionItem] = []
        
        for document in snapshot.documents {
            let data = document.data()
            
            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let amount = data["amount"] as? Double,
                  let description = data["description"] as? String,
                  let categoryId = data["categoryId"] as? String,
                  let createdAt = data["createdAt"] as? Timestamp else {
                throw NSError(domain: "TransactionManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode transaction data"])
            }
            
            // Fetch the category asynchronously
            let category: TransactionCategory?
            do {
                category = try await CategoryManager.shared.fetchCategoryById(categoryId: categoryId)
            } catch {
                print("Failed to fetch category: \(categoryId), \(error.localizedDescription)")
                category = nil
            }
            
            let transaction = TransactionItem(context: coreDataManager.viewContext)
            transaction.id = id
            transaction.amount = amount
            transaction.transactionDescription = description
            transaction.createdAt = createdAt.dateValue()
            transaction.category = category
            transactions.append(transaction)
        }
        
        return transactions
    }
    
    func deleteTransactionFromFirebase(transactionId: UUID) async throws {
        let auth = try AuthManager.shared.getAuthenticatedUser()
        let db = Firestore.firestore()

        // Reference to the user's transactions collection
        let userTransactionsRef = db.collection("users").document(auth.uid).collection("transactions")

        // Delete the transaction document
        try await userTransactionsRef.document(transactionId.uuidString).delete()
        
        print("Transaction deleted successfully from Firebase")
    }

    // MARK: - Core Data Transaction Management
    
    func fetchFromCoreData() throws -> [TransactionItem] {
        let viewContext = coreDataManager.viewContext
        let fetchRequest: NSFetchRequest<TransactionItem> = TransactionItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionItem.createdAt, ascending: false)]

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            throw error
        }
    }
    
    func saveToCoreData(description: String, amount: Double, category: TransactionCategory) throws -> TransactionItem{
        let context = coreDataManager.viewContext
        let newItem = TransactionItem(context: context)
        newItem.transactionDescription = description
        newItem.amount = amount
        newItem.category = category
        newItem.createdAt = Date()
        newItem.id = UUID()
        
        try context.save()
        return newItem
    }
    
    func deleteFromCoreData(transaction: TransactionItem) throws {
        let context = coreDataManager.viewContext
        context.delete(transaction)
        
        try context.save()
    }
}
