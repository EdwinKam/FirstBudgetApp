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

struct TransactionDbItem {
    var id: String // Transaction ID
    var amount: Double
    var description: String
    var date: Date
    // Add other fields as necessary
}

class TransactionManager {
    static let shared = TransactionManager()
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    // Core Data manager reference
    private let coreDataManager = CoreDataManager.shared
    
    private init() {}

    // MARK: - Firestore Transaction Management
    
    func createNewTransaction(auth: AuthDataResultModel, transaction: TransactionDbItem) {
        // Reference to the user's transactions collection
        let userTransactionDocRef = db.collection("users").document(auth.uid).collection("transactions").document(transaction.id)
        
        // Transaction data
        let transactionData: [String: Any] = [
            "id": transaction.id,
            "amount": transaction.amount,
            "description": transaction.description,
            "date": Timestamp(date: transaction.date)
        ]
        
        // Add the new transaction document under user
        userTransactionDocRef.setData(transactionData) { error in
            if let error = error {
                print("Error adding transaction: \(error.localizedDescription)")
            } else {
                print("Transaction successfully added!")
            }
        }
    }

    func getTransactions(auth: AuthDataResultModel) async throws -> [TransactionDbItem] {
        // Fetch all documents from the user's transactions collection
        let snapshot = try await db.collection("users").document(auth.uid).collection("transactions").getDocuments()
        
        let transactions: [TransactionDbItem] = snapshot.documents.compactMap { document in
            let data = document.data()
            
            let id = data["id"] as? String
            let amount = data["amount"] as? Double
            let description = data["description"] as? String
            let timestamp = data["date"] as? Timestamp
            
            guard let id = id,
                  let amount = amount,
                  let description = description,
                  let timestamp = timestamp else {
                return nil
            }
            
            return TransactionDbItem(
                id: id,
                amount: amount,
                description: description,
                date: timestamp.dateValue()
            )
        }
        
        return transactions
    }

    // MARK: - Core Data Transaction Management
    
    func fetchFromCoreData() throws -> [TransactionItem] {
        return try coreDataManager.fetchTransactions()
    }
    
    func saveToCoreData(description: String, amount: Double, category: TransactionCategory) throws {
        let context = coreDataManager.viewContext
        let newItem = TransactionItem(context: context)
        newItem.transactionDescription = description
        newItem.amount = amount
        newItem.category = category
        newItem.createdAt = Date()
        
        try context.save()
    }
}
