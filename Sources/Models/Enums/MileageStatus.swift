import Foundation
import SwiftUI

public enum MileageStatus: Int, Codable, CaseIterable, Identifiable, Hashable, Equatable {
    case great = 1
    case good
    case okay
    case maintenanceRecommended
    case maintenceNeeded
    
    public var title: String {
        switch self {
        case .great: return "Great"
        case .good: return "Good"
        case .okay: return "Okay"
        case .maintenanceRecommended: return "Recommended"
        case .maintenceNeeded: return "Needed"
        }
    }
    
    public var id: Int {
        return self.rawValue
    }
}

extension MileageStatus {
    public init(from decoder: Decoder) throws {
        self = try MileageStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .good
    }
}

public extension MileageStatus {
    var statusColor: Color {
        switch self {
        case .great: return .green
        case .good: return Color.green.opacity(0.6)
        case .okay: return Color.yellow
        case .maintenanceRecommended: return Color.orange
        case .maintenceNeeded: return Color.red
        }
    }
}
