import Foundation
import CoreData

public final class MileageMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var miles: Int16
    @NSManaged public var recommendedMiles: Int16
    @NSManaged public var bike: BikeMO?
    @NSManaged public var component: ComponentMO?
}
