import Foundation
import CoreDataModelDescription
import CoreData

fileprivate let bikeEntity: CoreDataEntityDescription = .entity(
    name: "_BikeMO",
    managedObjectClass: BikeMO.self,
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
)

fileprivate let brandEntity: CoreDataEntityDescription = .entity(
    name: "_BrandMO",
    managedObjectClass: BrandMO.self,
    attributes: [
        .attribute(name: "id", type: .integer16AttributeType, isOptional: true),
        .attribute(name: "isComponentOnly", type: .booleanAttributeType, isOptional: true),
        .attribute(name: "name", type: .stringAttributeType, isOptional: true)
    ],
    relationships: [
        .relationship(name: "bike", destination: "_BikeMO", toMany: false, inverse: "brand"),
        .relationship(name: "component", destination: "_ComponentMO", toMany: true, inverse: "brand"),
    ]
)

fileprivate let componentEntity: CoreDataEntityDescription = .entity(
    name: "_ComponentMO",
    managedObjectClass: ComponentMO.self,
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
)

fileprivate let maintenanceEntity: CoreDataEntityDescription = .entity(
    name: "_MaintenanceMO",
    managedObjectClass: MaintenanceMO.self,
    attributes: [
        .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
        .attribute(name: "serviceDate", type: .dateAttributeType, isOptional: true),
        .attribute(name: "serviceDescription", type: .stringAttributeType, isOptional: true)
    ],
    relationships: [
        .relationship(name: "bike", destination: "_BikeMO", toMany: false, inverse: "maintenances"),
        .relationship(name: "components", destination: "_ComponentMO", toMany: true, inverse: "maintenances"),
    ]
)

fileprivate let mileageEntity: CoreDataEntityDescription = .entity(
    name: "_MileageMO",
    managedObjectClass: MileageMO.self,
    attributes: [
        .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
        .attribute(name: "miles", type: .integer16AttributeType, isOptional: true),
        .attribute(name: "recommendedMiles", type: .integer16AttributeType, isOptional: true)
    ],
    relationships: [
        .relationship(name: "bike", destination: "_BikeMO", toMany: false, inverse: "mileage"),
        .relationship(name: "component", destination: "_ComponentMO", toMany: true, inverse: "mileage"),
    ]
)

fileprivate let rideEntity: CoreDataEntityDescription = .entity(
    name: "_RideMO",
    managedObjectClass: RideMO.self,
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

fileprivate let modelDescription = CoreDataModelDescription(
    entities: [
        bikeEntity,
        brandEntity,
        componentEntity,
        maintenanceEntity,
        mileageEntity,
        rideEntity
    ]
)

internal let cadenceModel = modelDescription.makeModel()
