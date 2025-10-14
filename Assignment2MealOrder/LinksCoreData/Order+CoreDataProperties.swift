import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var diningOption: String?
    @NSManaged public var orderID: Double
    @NSManaged public var status: String?
    @NSManaged public var tableNumber: Int16
    @NSManaged public var dishes: NSSet?

}

// MARK: Generated accessors for dishes
extension Order {

    @objc(addDishesObject:)
    @NSManaged public func addToDishes(_ value: Dish)

    @objc(removeDishesObject:)
    @NSManaged public func removeFromDishes(_ value: Dish)

    @objc(addDishes:)
    @NSManaged public func addToDishes(_ values: NSSet)

    @objc(removeDishes:)
    @NSManaged public func removeFromDishes(_ values: NSSet)

}

extension Order : Identifiable {

}
