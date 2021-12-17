import Foundation

public enum BikeType: Int, Codable, CaseIterable, Identifiable {
    case road = 1
    case mountain
    case gravel
    case commuter
    
    public var id: Int {
        return self.rawValue
    }
    
    public var title: String {
        switch self {
        case .road: return "Road"
        case .mountain: return "Mountain"
        case .gravel: return "Gravel"
        case .commuter: return "Commuter"
        }
    }
}

extension BikeType {
    public init(from decoder: Decoder) throws {
        self = try BikeType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .road
    }
}
