import ComposableArchitecture
import Combine
import Foundation
import Models
import World
import CoreDataStack

public struct MaintenanceClient {
    public struct Failure: Error, Equatable {}

    public var create: ([String], Maintenance) -> Effect<Maintenance, MaintenanceClient.Failure>
    public var delete: (Maintenance) -> Effect<Never, Never>
}

public extension MaintenanceClient {
    static var live: Self = Self(
        create: { componentIds, maintenance in
            let searchPredicate = NSPredicate(format: "id IN %@", componentIds)
            guard let components = try? Current.coreDataStack().fetch(ComponentMO.self, predicate: searchPredicate).get() else {
                return Effect(error: .init())
            }
            
            let modelObject = MaintenanceMO.initFrom(maintenance)
            modelObject.addToComponents(NSSet(array: components))
            
            return Current.coreDataStack().create(modelObject)
                .publisher
                .map({ $0.asMaintenance() })
                .mapError { _ in Failure() }
                .eraseToEffect()
            
        }, delete: { maintenance in
            let modelObject = MaintenanceMO.initFrom(maintenance)
            return .fireAndForget {
                Current.coreDataStack().delete(modelObject)
            }
        }
    )
}

public extension MaintenanceClient {
    static var failing: Self = Self(
        create: { _,_ in
            .failing("\(Self.self).create is unimplemented")
        }, delete: { _ in
            .failing("\(Self.self).delete is unimplemented")
        }
    )
    
    static var noop: Self = Self(
        create: { _,_ in
            .none
        }, delete: { _ in
            .none
        }
    )
}

public extension MaintenanceClient {
    static var mocked: Self = Self(
        create: { _, added in
            Effect(value: added)
                .eraseToEffect()
        }, delete: { _ in
            .none
        }
    )
}
