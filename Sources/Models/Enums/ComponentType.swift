import Foundation

public enum ComponentType: Int, Codable, CaseIterable, Identifiable, Hashable {
    case brakeCable = 1
    case brakeLever
    case brake
    case brakeRotor
    case cassette
    case chain
    case cogset
    case crankset
    case derailleur
    case dropper
    case fork
    case frame
    case handlebars
    case hub
    case innerTube
    case pedal
    case saddle
    case shifter
    case shiftCable
    case shockFront
    case shockRear
    case sprocket
    case stem
    case tire
    case wheel
    case other
    
    public var id: Int {
        return self.rawValue
    }
    
    public var title: String {
        switch self {
        case .brakeCable: return "Brake Cable"
        case .brakeLever: return "Brake Lever"
        case .brake: return "Brake"
        case .brakeRotor: return "Brake Rotor"
        case .cassette: return "Cassette"
        case .chain: return "Chain"
        case .cogset: return "Cogset"
        case .crankset: return "Crankset"
        case .derailleur: return "Derailleur"
        case .dropper: return "Dropper"
        case .fork: return "Fork"
        case .frame: return "Frame"
        case .handlebars: return "Handlebars"
        case .hub: return "Hub"
        case .innerTube: return "Inner Tube"
        case .pedal: return "Pedal"
        case .saddle: return "Saddle"
        case .shifter: return "Shifter"
        case .shiftCable: return "Shift Cable"
        case .shockFront: return "Shock-Front"
        case .shockRear: return "Shock-Rear"
        case .sprocket: return "Sprocket"
        case .stem: return "Stem"
        case .tire: return "Tire"
        case .wheel: return "Wheel"
        case .other: return "Other"
        }
    }
}

extension ComponentType {
    public init(from decoder: Decoder) throws {
        self = try ComponentType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .other
    }
}
