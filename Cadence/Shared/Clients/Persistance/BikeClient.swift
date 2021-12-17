import ComposableArchitecture
import Combine
import Models

struct BikeClient {
    struct Failure: Error, Equatable {}
    
    var fetch: () -> Effect<[Bike], BikeClient.Failure>
    var create: (Bike) -> Effect<Bike, BikeClient.Failure>
    var update: (Bike) -> Effect<Bike, BikeClient.Failure>
    var delete: (Bike) -> Effect<Never, Never>
}

extension BikeClient {
    static var live: Self = Self(
        fetch: {
            Current.coreDataStack().fetch(BikeMO.self, predicate: nil, limit: nil)
                .publisher
                .map({ $0.map({ $0.asBike() }) })
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, create: { model in
            let managedObject = BikeMO.initFrom(model)
            return Current.coreDataStack().create(managedObject)
                .publisher
                .map({ $0.asBike() })
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, update: { model in
            guard let managedObject = try? Current.coreDataStack().fetchFirst(BikeMO.self, predicate: NSPredicate(format: "id == %@", model.id.uuidString)).get() else {
                return Effect(error: .init())
            }
            
            if model.name != managedObject.name {
                managedObject.name = model.name
            }

            if model.mileage.miles != (managedObject.mileage?.miles ?? 0) {
                managedObject.mileage?.miles = Int16(model.mileage.miles)
                
                let managedComponents = managedObject.components as? Set<ComponentMO>
                var updatedComponents = managedComponents?.map { component -> ComponentMO in
                    var updatedComponent = component
                    updatedComponent.mileage?.miles = Int16(model.mileage.miles)
                    return updatedComponent
                }
                
                if let components = updatedComponents {
                    let cdValue = NSSet(array: components)
                    managedObject.components = cdValue
                }
            }
            
            return Current.coreDataStack().update(managedObject)
                .publisher
                .map({ $0.asBike() })
                .mapError { _ in Failure() }
                .eraseToEffect()
        }, delete: { model in
            guard let managedObject = try? Current.coreDataStack().fetchFirst(BikeMO.self, predicate: NSPredicate(format: "id == %@", model.id.uuidString)).get() else {
                return .none
            }
            
            return .fireAndForget {
                Current.coreDataStack().delete(managedObject)
            }
        }
    )
}

extension BikeClient {
    static var failing: Self = Self(
        fetch: {
            .failing("\(Self.self).failing is unimplemented")
        }, create: { _ in
            .failing("\(Self.self).create is unimplemented")
        }, update: { _ in
            .failing("\(Self.self).update is unimplemented")
        }, delete: { _ in
            .failing("\(Self.self).delete is unimplemented")
        }
    )
    
    static var noop: Self = Self(
        fetch: {
            .none
        }, create: { _ in
            .none
        }, update: { _ in
            .none
        }, delete: { _ in
            .none
        }
    )
}

#if DEBUG
private let queue = DispatchQueue(label: "BikeClient")
private var bikes: [Bike] = []
extension BikeClient {
    
    static var mocked: Self = Self(
        fetch: {
            Effect(value: bikes)
                .eraseToEffect()
        }, create: { addedBike in
            bikes.append(addedBike)
            return Effect(value: addedBike)
                .eraseToEffect()
        }, update: { updated in
            return Effect(value: updated)
                .eraseToEffect()
        }, delete: { bike in
            bikes.removeAll(where: { $0.id == bike.id })
            return .none
        }
    )
}
#endif
