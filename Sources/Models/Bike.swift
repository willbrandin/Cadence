import Foundation

public struct Bike: Codable, Identifiable, Equatable {
    public init(id: UUID, name: String, components: [Component], bikeTypeId: BikeType, mileage: Mileage, maintenances: [Maintenance]? = nil, brand: Brand, rides: [Ride]) {
        self.id = id
        self.name = name
        self.components = components
        self.bikeTypeId = bikeTypeId
        self.mileage = mileage
        self.maintenances = maintenances
        self.brand = brand
        self.rides = rides
    }
    
    public var id: UUID
    public var name: String
    public var components: [Component]
    public var bikeTypeId: BikeType
    public var mileage: Mileage
    public var maintenances: [Maintenance]?
    public var brand: Brand
    public var rides: [Ride]
    
    public var componentMileageAvg: Mileage {
        let miles = components.map({ $0.mileage.miles }).reduce(0, +)
        let recommended = components.map({ $0.mileage.recommendedMiles }).reduce(0, +)
        
        return Mileage(id: .init(), miles: miles, recommendedMiles: max(1, recommended))
    }
}

public extension Bike {
    static let yetiMountain = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        name: "YETI 165C",
        components: [
            .shimanoSLXBrakes,
            .shimanoXLTBrakeRotor,
            .racefaceCogsette,
            .wtbFrontWheelSet,
            .yeti165Frame,
            .racefaceCarbon69Handlebars
        ],
        bikeTypeId: .mountain,
        mileage: .good,
        maintenances: [],
        brand: .yeti,
        rides: []
    )
    
    static let canyonRoad = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "Canyon 123CC",
        components: [
            .shimanoSLXBrakes,
            .shimanoXLTBrakeRotor,
            .racefaceCogsette,
            .wtbFrontWheelSet,
            .canyonFrame
        ],
        bikeTypeId: .road,
        mileage: .okay,
        maintenances: [],
        brand: .canyon,
        rides: []
    )
    
    static let specializedMountain = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "Specialized Rockhopper",
        components: [
            .shimanoSLXBrakes,
            .shimanoXLTBrakeRotor,
            .racefaceCogsette,
            .wtbFrontWheelSet
        ],
        bikeTypeId: .mountain,
        mileage: .high,
        maintenances: [],
        brand: .specialized,
        rides: []
    )
}
