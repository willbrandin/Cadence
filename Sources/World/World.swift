import Foundation
import UIKit

#if DEBUG
public var Current = World()
#else
public let Current = World()
#endif

public struct World {
    public var date = { Date() }
    public var calendar = Calendar.autoupdatingCurrent
    public var locale = Locale.autoupdatingCurrent
    public var timeZone = TimeZone.autoupdatingCurrent
    public var uuid: () -> UUID = { UUID() }
}

extension World {
    public static let mixed = Self(
        date: { Date() },
        calendar: Calendar(identifier: .buddhist),
        locale: Locale(identifier: "es_ES"),
        timeZone: TimeZone(identifier: "Pacific/Honolulu")!
    )
}

public extension World {
    func dateFormatter(
        dateStyle: DateFormatter.Style = .none,
        timeStyle: DateFormatter.Style = .none
    )
    -> DateFormatter {
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        
        formatter.calendar = self.calendar
        formatter.locale = self.locale
        formatter.timeZone = self.timeZone
        
        return formatter
    }
}
