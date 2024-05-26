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

    @NSManaged public var transactionDescription: String?

}

extension TransactionItem : Identifiable {

}
