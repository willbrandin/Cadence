import Foundation

public struct Brand: Codable, Identifiable, Equatable, Hashable {
    public init(id: Int, brand: String, isComponentManufacturerOnly: Bool) {
        self.id = id
        self.brand = brand
        self.isComponentManufacturerOnly = isComponentManufacturerOnly
    }
    
    public var id: Int
    public let brand: String
    public let isComponentManufacturerOnly: Bool
}

public extension Brand {
    static let shimano = Brand(
        id: 0,
        brand: "Shimano",
        isComponentManufacturerOnly: true)
    static let sram = Brand(
        id: 1,
        brand: "SRAM",
        isComponentManufacturerOnly: true)
    static let yeti = Brand(
        id: 2,
        brand: "YETI",
        isComponentManufacturerOnly: false)
    static let specialized = Brand(
        id: 3,
        brand: "Specialized",
        isComponentManufacturerOnly: false)
    static let canyon = Brand(
        id: 4,
        brand: "Canyon",
        isComponentManufacturerOnly: false)
    static let raceface = Brand(
        id: 5,
        brand: "Raceface",
        isComponentManufacturerOnly: true)
    static let wtb = Brand(
        id: 6,
        brand: "WTB",
        isComponentManufacturerOnly: true)
}

public extension Array where Element == Brand {
    static let brandList: [Brand] = [
        .shimano,
        .sram,
        .yeti,
        .specialized,
        .canyon,
        .raceface,
        .wtb
    ]
    
    static let componentOnlyBrands: [Brand] = [
        .shimano,
        .sram,
        .raceface,
        .wtb
    ]
    
    static let bikeOnlyBrands: [Brand] = [
        .yeti,
        .specialized,
        .canyon
    ]
}
