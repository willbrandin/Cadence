import Foundation

public extension Date {
    static func initFromComponents(
        year: Int,
        month: Int,
        day: Int,
        timeZone: String = "MST",
        hour: Int,
        minute: Int
    ) -> Date? {
        // Specify date components
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.timeZone = TimeZone(abbreviation: timeZone) // Mountain Standard Time
        dateComponents.hour = hour
        dateComponents.minute = minute

        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        let date = userCalendar.date(from: dateComponents)
        return date
    }
}
