//
//  TransactionItem+CoreDataProperties.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/27/24.
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
    @NSManaged public var createdAt: Date?
    @NSManaged public var category: TransactionCategory?
    
    override public func willSave() {
        super.willSave()
        
        let now = Date()
        
        if self.createdAt == nil {
            self.createdAt = now
        }
    }

}

extension TransactionItem : Identifiable {

}
