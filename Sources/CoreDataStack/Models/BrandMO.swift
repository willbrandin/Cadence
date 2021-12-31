import Foundation
import CoreData

public final class BrandMO: NSManagedObject {
    @NSManaged public var id: Int16
    @NSManaged public var isComponentOnly: Bool
    @NSManaged public var name: String?
    
    @NSManaged public var bike: BikeMO?
    @NSManaged public var component: ComponentMO?
}
