import Models

public struct UserSettings: Codable, Equatable {
    public init(
        colorScheme: ColorScheme = .system,
        distanceUnit: DistanceUnit = .miles,
        appIcon: AppIcon? = nil,
        accentColor: AccentColor = .blue
    ) {
        self.colorScheme = colorScheme
        self.distanceUnit = distanceUnit
        self.appIcon = appIcon
        self.accentColor = accentColor
    }
    
    public var colorScheme: ColorScheme
    public var distanceUnit: DistanceUnit
    public var appIcon: AppIcon?
    public var accentColor: AccentColor
}
