//
//  TransactionCategory+CoreDataProperties.swift
//  FirstBudgetApp
//
//  Created by Edwin Kam on 5/26/24.
//
//

import Foundation
import CoreData


extension TransactionCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionCategory> {
        return NSFetchRequest<TransactionCategory>(entityName: "TransactionCategory")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?

}

extension TransactionCategory : Identifiable {

}
