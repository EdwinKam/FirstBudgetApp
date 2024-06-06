//
//  TransactionItem+CoreDataProperties.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 6/5/24.
//
//

import Foundation
import CoreData


extension TransactionItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionItem> {
        return NSFetchRequest<TransactionItem>(entityName: "TransactionItem")
    }

    @NSManaged public var amount: Double
    @NSManaged public var createdAt: Date?
    @NSManaged public var transactionDescription: String
    @NSManaged public var id: UUID
    @NSManaged public var category: TransactionCategory?

}

extension TransactionItem : Identifiable {

}
