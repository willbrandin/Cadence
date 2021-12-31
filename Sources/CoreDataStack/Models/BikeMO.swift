import Foundation
import CoreData

public final class BikeMO: NSManagedObject {
    @NSManaged public var bikeTypeId: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    
    @NSManaged public var brand: BrandMO?
    @NSManaged public var components: NSSet?
    @NSManaged public var maintenances: NSSet?
    @NSManaged public var mileage: MileageMO?
    @NSManaged public var rides: NSSet?
}
