//
//  TransactionItem+CoreDataProperties.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/26/24.
//
//

import Foundation
import CoreData


extension TransactionItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionItem> {
        return NSFetchRequest<TransactionItem>(entityName: "TransactionItem")
    }

    @NSManaged public var amount: Double
    @NSManaged public var transactionDescription: String?
    @NSManaged public var categoryId: UUID?
    @NSManaged public var category: NSSet?

}

// MARK: Generated accessors for category
extension TransactionItem {

    @objc(addCategoryObject:)
    @NSManaged public func addToCategory(_ value: TransactionCategory)

    @objc(removeCategoryObject:)
    @NSManaged public func removeFromCategory(_ value: TransactionCategory)

    @objc(addCategory:)
    @NSManaged public func addToCategory(_ values: NSSet)

    @objc(removeCategory:)
    @NSManaged public func removeFromCategory(_ values: NSSet)

}

extension TransactionItem : Identifiable {

}
