import ComposableArchitecture
import Combine
import Models
import World
import CoreDataStack

public struct RideClient {
    public struct Failure: Error, Equatable {}
    public var create: (String, [String], Ride) -> Effect<Ride, RideClient.Failure>
}

public extension RideClient {
    static var live: Self = Self(
        create: { bikeId, componentIds, ride in
            let searchPredicate = NSPredicate(format: "id IN %@", componentIds)
            guard let components = try? Current.coreDataStack().fetch(_ComponentMO.self, predicate: searchPredicate).get() else {
                return Effect(error: .init())
            }
            
            guard let bike = try? Current.coreDataStack().fetchFirst(_BikeMO.self, predicate: NSPredicate(format: "id == %@", bikeId)).get() else {
                return Effect(error: .init())
            }
            
            let rideMO = _RideMO.initFrom(ride)
            rideMO.bike = bike
            rideMO.components = NSSet(array: components)

            return Current.coreDataStack().create(rideMO)
                .publisher
                .map { $0.asRide() }
                .mapError { _ in Failure() }
                .eraseToEffect()
        }
    )
}

public extension RideClient {
    static var failing: Self = Self(
        create: { _, _, _ in
            .failing("\(Self.self).create is unimplemented")
        }
    )
    
    static var noop: Self = Self(
        create: { _, _, _ in
            .none
        }
    )
}


public extension RideClient {
    static var mocked: Self = Self(
        create: { _, _, new in
            Effect(value: new)
                .eraseToEffect()
        }
    )
}
