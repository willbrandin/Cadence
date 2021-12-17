import ComposableArchitecture
import Combine
import Models

struct RideClient {
    struct Failure: Error, Equatable {}
    var create: (String, [String], Ride) -> Effect<Ride, RideClient.Failure>
}

extension RideClient {
    static var live: Self = Self(
        create: { bikeId, componentIds, ride in
            let searchPredicate = NSPredicate(format: "id IN %@", componentIds)
            guard let components = try? Current.coreDataStack().fetch(ComponentMO.self, predicate: searchPredicate).get() else {
                return Effect(error: .init())
            }
            
            guard let bike = try? Current.coreDataStack().fetchFirst(BikeMO.self, predicate: NSPredicate(format: "id == %@", bikeId)).get() else {
                return Effect(error: .init())
            }
            
            let rideMO = RideMO.initFrom(ride)
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

extension RideClient {
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


extension RideClient {
    static var mocked: Self = Self(
        create: { _, _, new in
            Effect(value: new)
                .eraseToEffect()
        }
    )
}
