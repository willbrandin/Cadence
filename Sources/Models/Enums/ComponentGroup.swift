import Foundation

public enum ComponentGroup: Int, Codable, CaseIterable, Identifiable, Hashable {
    case brakes = 1
    case drivetrain
    case frame
    case suspension
    case wheelset
    case handlebars
    case miscellaneus
    
    public var id: Int {
        return self.rawValue
    }
    
    public var title: String {
        switch self {
        case .brakes: return "Brakes"
        case .drivetrain: return "Drivetrain"
        case .frame: return "Frame"
        case .suspension: return "Suspension"
        case .wheelset: return "Wheelset"
        case .handlebars: return "Handlebars"
        case .miscellaneus: return "Misc"
        }
    }
}

extension ComponentGroup {
    public init(from decoder: Decoder) throws {
        self = try ComponentGroup(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .miscellaneus
    }
}
