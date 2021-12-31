import Foundation
import CoreData

public final class MaintenanceMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var serviceDate: Date?
    @NSManaged public var serviceDescription: String?
    
    @NSManaged public var bike: BikeMO?
    @NSManaged public var components: NSSet?
}
