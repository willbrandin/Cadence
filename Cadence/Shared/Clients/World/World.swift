import Foundation
import UIKit

#if DEBUG
var Current = World()
#else
let Current = World()
#endif

struct World {
    var date = { Date() }
    var calendar = Calendar.autoupdatingCurrent
    var locale = Locale.autoupdatingCurrent
    var timeZone = TimeZone.autoupdatingCurrent
    var uuid: () -> UUID = { UUID() }
    var coreDataStack: () -> CoreDataStack = { CoreDataStack.shared }
}

extension World {
    static let mixed = Self(
        date: { Date() },
        calendar: Calendar(identifier: .buddhist),
        locale: Locale(identifier: "es_ES"),
        timeZone: TimeZone(identifier: "Pacific/Honolulu")!
    )
}

extension World {
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
