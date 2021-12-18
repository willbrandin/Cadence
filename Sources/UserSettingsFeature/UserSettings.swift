import Models

public struct UserSettings: Codable, Equatable {
    public init(
        colorScheme: ColorScheme,
        distanceUnit: DistanceUnit,
        appIcon: AppIcon? = nil
    ) {
        self.colorScheme = colorScheme
        self.distanceUnit = distanceUnit
        self.appIcon = appIcon
    }
    
    public var colorScheme: ColorScheme
    public var distanceUnit: DistanceUnit
    public var appIcon: AppIcon?
}
