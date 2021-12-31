import Foundation
import CoreData

public final class ComponentMO: NSManagedObject {
    @NSManaged public var addedToBikeDate: Date?
    @NSManaged public var componentDescription: String?
    @NSManaged public var componentGroupId: Int16
    @NSManaged public var componentTypeId: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var model: String?

    @NSManaged public var bike: BikeMO?
    @NSManaged public var brand: BrandMO?
    @NSManaged public var maintenances: NSSet?
    @NSManaged public var mileage: MileageMO?
    @NSManaged public var rides: NSSet?
}
