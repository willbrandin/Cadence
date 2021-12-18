import ComposableArchitecture
import CoreDataStack
import Foundation
import BrandClient
import FileClient
import EmailClient
import World
import BikeClient
import ComponentClient
import MaintenanceClient
import MileageClient
import RideClient

struct AppCoreEnvironment {
    var uiApplicationClient: UIApplicationClient
    var uiUserInterfaceClient: UIUserInterfaceStyleClient
    var bikeClient: BikeClient
    var brandAPIClient: BrandClient
    var componentClient: ComponentClient
    var maintenanceClient: MaintenanceClient
    var mileageClient: MileageClient
    var rideClient: RideClient
    var userDefaults: UserDefaultsClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var fileClient: FileClient
    var date: () -> Date
    var uuid: () -> UUID
    var storeKitClient: StoreKitClient
    var shareSheetClient: ShareSheetClient
    var emailClient: EmailClient
    var cloudKitClient: CloudKitClient
}

extension AppCoreEnvironment {
    static let live = Self(
        uiApplicationClient: .live,
        uiUserInterfaceClient: .live,
        bikeClient: .live,
        brandAPIClient: .live,
        componentClient: .live,
        maintenanceClient: .live,
        mileageClient: .live,
        rideClient: .live,
        userDefaults: .live(),
        mainQueue: .main,
        fileClient: .live,
        date: Current.date,
        uuid: Current.uuid,
        storeKitClient: .live,
        shareSheetClient: .live,
        emailClient: .live,
        cloudKitClient: .live
    )
    
    static let nonPersisted = Self(
        uiApplicationClient: .live,
        uiUserInterfaceClient: .live,
        bikeClient: .mocked,
        brandAPIClient: .mocked,
        componentClient: .mocked,
        maintenanceClient: .mocked,
        mileageClient: .mocked,
        rideClient: .mocked,
        userDefaults: .noop,
        mainQueue: .main,
        fileClient: .noop,
        date: Current.date,
        uuid: Current.uuid,
        storeKitClient: .live,
        shareSheetClient: .live,
        emailClient: .live,
        cloudKitClient: .noop
    )

    static var dev: Self {
        
        Current.coreDataStack = { CoreDataStack.preview }

        return Self(
            uiApplicationClient: .live,
            uiUserInterfaceClient: .live,
            bikeClient: .live,
            brandAPIClient: .mocked,
            componentClient: .live,
            maintenanceClient: .live,
            mileageClient: .live,
            rideClient: .live,
            userDefaults: .live(),
            mainQueue: .main,
            fileClient: .live,
            date: Current.date,
            uuid: Current.uuid,
            storeKitClient: .live,
            shareSheetClient: .live,
            emailClient: .live,
            cloudKitClient: .live
        )
    }
    static let failing = Self(
        uiApplicationClient: .failing,
        uiUserInterfaceClient: .failing,
        bikeClient: .failing,
        brandAPIClient: .alwaysFailing,
        componentClient: .failing,
        maintenanceClient: .failing,
        mileageClient: .failing,
        rideClient: .failing,
        userDefaults: .failing,
        mainQueue: .failing,
        fileClient: .failing,
        date: Current.date,
        uuid: Current.uuid,
        storeKitClient: .noop,
        shareSheetClient: .noop,
        emailClient: .noop,
        cloudKitClient: .noop
    )
}
