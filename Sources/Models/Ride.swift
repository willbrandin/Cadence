import Foundation

public struct Ride: Codable, Identifiable, Equatable {
    public  init(id: UUID, date: Date, distance: Int) {
        self.id = id
        self.date = date
        self.distance = distance
    }
    
    public var id: UUID
    public var date: Date
    public var distance: Int
}
