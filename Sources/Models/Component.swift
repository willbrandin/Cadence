import Foundation
import DateHelpers
import World

public struct Component: Codable, Identifiable, Equatable, Hashable {
    public init(id: UUID, model: String? = nil, description: String? = nil, componentTypeId: ComponentType, componentGroupId: ComponentGroup, addedToBikeDate: Date, mileage: Mileage, maintenances: [Maintenance], brand: Brand) {
        self.id = id
        self.model = model
        self.description = description
        self.componentTypeId = componentTypeId
        self.componentGroupId = componentGroupId
        self.addedToBikeDate = addedToBikeDate
        self.mileage = mileage
        self.maintenances = maintenances
        self.brand = brand
    }
    
    public var id: UUID
    public var model: String?
    public var description: String?
    public var componentTypeId: ComponentType
    public var componentGroupId: ComponentGroup // Is this a choice for the user?
    public var addedToBikeDate: Date
    public var mileage: Mileage
    public var maintenances: [Maintenance]
    public var brand: Brand
    
    public var addedToBikeDateText: String {
        let formatter = Current.dateFormatter(dateStyle: .long, timeStyle: .none)
        return formatter.string(from: addedToBikeDate)
    }
}

public extension Component {
    var cellTitle: String {
        if let description = description, !description.isEmpty {
            return description
        } else if let model = model, !model.isEmpty {
            return "\(brand.brand) - \(model)"
        }
        
        return "\(brand.brand) - \(componentTypeId.title)"
    }
}

public extension Component {
    static let shimanoSLXBrakes = Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        model: "SLX",
        description: nil,
        componentTypeId: .brakeLever,
        componentGroupId: .brakes,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .good,
        maintenances: [],
        brand: .shimano)
    
    static let shimanoXLTBrakeRotor = Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        model: "XLT",
        description: "Brake Rotor",
        componentTypeId: .brakeRotor,
        componentGroupId: .brakes,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .good,
        maintenances: [],
        brand: .shimano)
    
    static let racefaceCogsette = Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        model: nil,
        description: "Cogsette",
        componentTypeId: .cogset,
        componentGroupId: .drivetrain,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .good,
        maintenances: [],
        brand: .raceface)
    
    static let wtbFrontWheelSet = Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        model: nil,
        description: "WTB-Front",
        componentTypeId: .tire,
        componentGroupId: .wheelset,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .good,
        maintenances: [],
        brand: .wtb)
    
    static let yeti165Frame =  Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        model: nil,
        description: "YETI - 165 Frame",
        componentTypeId: .frame,
        componentGroupId: .frame,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .good,
        maintenances: [],
        brand: .yeti)
    
    static let canyonFrame = Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        model: nil,
        description: "Canyon Frame",
        componentTypeId: .frame,
        componentGroupId: .frame,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .good,
        maintenances: [],
        brand: .canyon)
    
    static let racefaceCarbon69Handlebars = Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
        model: "Carbon 69",
        description: nil,
        componentTypeId: .handlebars,
        componentGroupId: .handlebars,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .okay,
        maintenances: [],
        brand: .raceface
    )
    
    static let shimanoSLXRearDerailleur = Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
        model: "SLX",
        description: "Rear Derailleur",
        componentTypeId: .derailleur,
        componentGroupId: .drivetrain,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .low,
        maintenances: [],
        brand: .shimano
    )
    
    static let yeti165Frame_WithMaintenance =  Component(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
        model: nil,
        description: "YETI - 165 Frame",
        componentTypeId: .frame,
        componentGroupId: .frame,
        addedToBikeDate: Date.initFromComponents(year: 2020, month: 11, day: 1, hour: 8, minute: 0)!,
        mileage: .good,
        maintenances: .maintenances,
        brand: .yeti)
}
