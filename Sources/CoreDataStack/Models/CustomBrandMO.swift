import Foundation
import CoreData

public final class CustomBrandMO: NSManagedObject {
    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var isComponentOnly: Bool
}
