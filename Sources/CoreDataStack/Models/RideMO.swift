import Foundation
import CoreData

public final class RideMO: NSManagedObject {
    @NSManaged public var date: Date?
    @NSManaged public var distance: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var bike: BikeMO?
    @NSManaged public var components: NSSet?
}
