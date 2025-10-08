//
//  Dish+CoreDataProperties.swift
//  Assignment2MealOrder
//
//  Created by Alexander Hejaij on 25/9/2025.
//
//

import Foundation
import CoreData


extension Dish {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dish> {
        return NSFetchRequest<Dish>(entityName: "Dish")
    }

    @NSManaged public var dishID: Double
    @NSManaged public var dishName: String?
    @NSManaged public var dishType: String?
    @NSManaged public var image: Data?
    @NSManaged public var ingredients: String?
    @NSManaged public var price: Double
    @NSManaged public var orders: NSSet?

}

// MARK: Generated accessors for orders
extension Dish {

    @objc(addOrdersObject:)
    @NSManaged public func addToOrders(_ value: Order)

    @objc(removeOrdersObject:)
    @NSManaged public func removeFromOrders(_ value: Order)

    @objc(addOrders:)
    @NSManaged public func addToOrders(_ values: NSSet)

    @objc(removeOrders:)
    @NSManaged public func removeFromOrders(_ values: NSSet)

}

extension Dish : Identifiable {

}
