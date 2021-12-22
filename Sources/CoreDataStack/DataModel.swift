import Foundation
import CoreDataModelDescription
import CoreData

public final class _BikeMO: NSManagedObject {
    @NSManaged public var bikeTypeId: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    
    @NSManaged public var brand: _BrandMO?
    @NSManaged public var components: NSSet?
    @NSManaged public var maintenances: NSSet?
    @NSManaged public var mileage: _MileageMO?
    @NSManaged public var rides: NSSet?
}

public final class _BrandMO: NSManagedObject {
    @NSManaged public var id: Int16
    @NSManaged public var isComponentOnly: Bool
    @NSManaged public var name: String?
    
    @NSManaged public var bike: _BikeMO?
    @NSManaged public var component: _ComponentMO?
}

public final class _ComponentMO: NSManagedObject {
    @NSManaged public var addedToBikeDate: Date?
    @NSManaged public var componentDescription: String?
    @NSManaged public var componentGroupId: Int16
    @NSManaged public var componentTypeId: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var model: String?

    @NSManaged public var bike: _BikeMO?
    @NSManaged public var brand: _BrandMO?
    @NSManaged public var maintenances: NSSet?
    @NSManaged public var mileage: _MileageMO?
    @NSManaged public var rides: NSSet?
}

public final class _MaintenanceMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var serviceDate: Date?
    @NSManaged public var serviceDescription: String?
    
    @NSManaged public var bike: _BikeMO?
    @NSManaged public var components: NSSet?
}

public final class _MileageMO: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var miles: Int16
    @NSManaged public var recommendedMiles: Int16
    @NSManaged public var bike: _BikeMO?
    @NSManaged public var component: _ComponentMO?
}

public final class _RideMO: NSManagedObject {
    @NSManaged public var date: Date?
    @NSManaged public var distance: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var bike: _BikeMO?
    @NSManaged public var components: NSSet?
}

internal let modelDescription = CoreDataModelDescription(
    entities: [
        .entity(
            name: "_BikeMO",
            managedObjectClass: _BikeMO.self,
            attributes: [
                .attribute(name: "bikeTypeId", type: .integer16AttributeType, isOptional: true),
                .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
                .attribute(name: "name", type: .stringAttributeType, isOptional: true)
            ],
            relationships: [
                .relationship(name: "brand", destination: "_BrandMO", toMany: false, inverse: "bike"),
                .relationship(name: "components", destination: "_ComponentMO", toMany: true, inverse: "bike"),
                .relationship(name: "maintenances", destination: "_MaintenanceMO", toMany: true, inverse: "bike"),
                .relationship(name: "mileage", destination: "_MileageMO", toMany: false, inverse: "bike"),
                .relationship(name: "rides", destination: "_RideMO", toMany: true, inverse: "bike")
            ]
        ),
        .entity(
            name: "_BrandMO",
            managedObjectClass: _BrandMO.self,
            attributes: [
                .attribute(name: "id", type: .integer16AttributeType, isOptional: true),
                .attribute(name: "isComponentOnly", type: .booleanAttributeType, isOptional: true),
                .attribute(name: "name", type: .stringAttributeType, isOptional: true)
            ],
            relationships: [
                .relationship(name: "bike", destination: "_BikeMO", toMany: false, inverse: "brand"),
                .relationship(name: "component", destination: "_ComponentMO", toMany: true, inverse: "brand"),
            ]
        ),
        .entity(
            name: "_ComponentMO",
            managedObjectClass: _ComponentMO.self,
            attributes: [
                .attribute(name: "addedToBikeDate", type: .dateAttributeType, isOptional: true),
                .attribute(name: "componentDescription", type: .stringAttributeType, isOptional: true),
                .attribute(name: "componentGroupId", type: .integer16AttributeType, isOptional: true),
                .attribute(name: "componentTypeId", type: .integer16AttributeType, isOptional: true),
                .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
                .attribute(name: "model", type: .stringAttributeType, isOptional: true)
            ],
            relationships: [
                .relationship(name: "bike", destination: "_BikeMO", toMany: false, inverse: "components"),
                .relationship(name: "brand", destination: "_BrandMO", toMany: false, inverse: "component"),
                .relationship(name: "maintenances", destination: "_MaintenanceMO", toMany: true, inverse: "components"),
                .relationship(name: "mileage", destination: "_MileageMO", toMany: false, inverse: "component"),
                .relationship(name: "rides", destination: "_RideMO", toMany: true, inverse: "components")
            ]
        ),
        .entity(
            name: "_MaintenanceMO",
            managedObjectClass: _MaintenanceMO.self,
            attributes: [
                .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
                .attribute(name: "serviceDate", type: .dateAttributeType, isOptional: true),
                .attribute(name: "serviceDescription", type: .stringAttributeType, isOptional: true)
            ],
            relationships: [
                .relationship(name: "bike", destination: "_BikeMO", toMany: false, inverse: "maintenances"),
                .relationship(name: "components", destination: "_ComponentMO", toMany: true, inverse: "maintenances"),
            ]
        ),
        .entity(
            name: "_MileageMO",
            managedObjectClass: _MileageMO.self,
            attributes: [
                .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
                .attribute(name: "miles", type: .integer16AttributeType, isOptional: true),
                .attribute(name: "recommendedMiles", type: .integer16AttributeType, isOptional: true)
            ],
            relationships: [
                .relationship(name: "bike", destination: "_BikeMO", toMany: false, inverse: "mileage"),
                .relationship(name: "component", destination: "_ComponentMO", toMany: true, inverse: "mileage"),
            ]
        ),
        .entity(
            name: "_RideMO",
            managedObjectClass: _RideMO.self,
            attributes: [
                .attribute(name: "date", type: .dateAttributeType, isOptional: true),
                .attribute(name: "distance", type: .integer16AttributeType, isOptional: true),
                .attribute(name: "id", type: .UUIDAttributeType, isOptional: true)
            ],
            relationships: [
                .relationship(name: "bike", destination: "_BikeMO", toMany: false, inverse: "rides"),
                .relationship(name: "components", destination: "_ComponentMO", toMany: true, inverse: "rides")
            ]
        )
    ]
)

internal let cadenceModel = modelDescription.makeModel()

