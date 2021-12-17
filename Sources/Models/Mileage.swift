import Foundation

public struct Mileage: Codable, Identifiable, Equatable, Hashable {
    public  init(id: UUID, miles: Int, recommendedMiles: Int) {
        self.id = id
        self.miles = miles
        self.recommendedMiles = recommendedMiles
    }
    
    public var id: UUID
    public var miles: Int
    public var recommendedMiles: Int
    
    public var mileageStatusTypeId: MileageStatus {
        let miles = Float(miles)
        let recommended = Float(recommendedMiles)
        let percent = miles / recommended
        let minValue = min(percent, 1)
        
        if minValue > 0.9 {
            return .maintenceNeeded
        } else if minValue > 0.7 {
            return .maintenanceRecommended
        } else  if minValue > 0.5 {
            return .okay
        } else if minValue > 0.25 {
            return .good
        } else {
            return .great
        }
    }
}

public extension Mileage {
    static let base = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        miles: 0,
        recommendedMiles: 500
    )
    
    static let low = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        miles: 10,
        recommendedMiles: 500
    )
    
    static let good = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        miles: 200,
        recommendedMiles: 500
    )
    
    static let okay = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        miles: 270,
        recommendedMiles: 500
    )
    
    static let upper = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        miles: 400,
        recommendedMiles: 500
    )
    
    static let high = Self(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
        miles: 490,
        recommendedMiles: 500
    )
}
