import Foundation
import World

public struct Maintenance: Codable, Identifiable, Equatable, Hashable {
    public init(id: UUID, description: String?, serviceDate: Date) {
        self.id = id
        self.description = description
        self.serviceDate = serviceDate
    }
    
    public var id: UUID
    public let description: String?
    public let serviceDate: Date
    
    public var serviceDateString: String {
        let formatter = Current.dateFormatter(dateStyle: .short, timeStyle: .none)
        return formatter.string(from: serviceDate)
    }
}

// MARK: - Mocks

extension Maintenance {
    static let greased = Maintenance(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        description: "Greased Component",
        serviceDate: .initFromComponents(year: 2021, month: 04, day: 21, hour: 8, minute: 0)!)
    static let regularMaintenance = Maintenance(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        description: "Routine Maintentance",
        serviceDate: .initFromComponents(year: 2021, month: 04, day: 5, hour: 8, minute: 0)!)
    static let breakBleed = Maintenance(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        description: "Break Bleed",
        serviceDate: .initFromComponents(year: 2021, month: 3, day: 21, hour: 8, minute: 0)!)
    static let derailleurAdjusted = Maintenance(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        description: "Derailleur Adjusted",
        serviceDate: .initFromComponents(year: 2021, month: 2, day: 21, hour: 8, minute: 0)!)
    static let airShocks = Maintenance(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        description: "Aired Shocks",
        serviceDate: .initFromComponents(year: 2021, month: 2, day: 1, hour: 8, minute: 0)!)
    static let shiftCableAdjusted = Maintenance(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        description: "Shift Cable Adjusted",
        serviceDate: .initFromComponents(year: 2020, month: 12, day: 21, hour: 8, minute: 0)!)
}

extension Array where Element == Maintenance {
    static let maintenances: [Maintenance] = [
        .greased, .regularMaintenance, .breakBleed, .derailleurAdjusted, .airShocks, .shiftCableAdjusted
    ]
}
