import CloudKitClient
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
import UserDefaultsClient
import StoreKitClient
import ShareSheetClient
import UIApplicationClient
import UIUserInterfaceStyleClient

public struct AppCoreEnvironment {
    public init(
        uiApplicationClient: UIApplicationClient,
        uiUserInterfaceClient: UIUserInterfaceStyleClient,
        bikeClient: BikeClient,
        brandAPIClient: BrandClient,
        componentClient: ComponentClient,
        maintenanceClient: MaintenanceClient,
        mileageClient: MileageClient,
        rideClient: RideClient,
        userDefaults: UserDefaultsClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        fileClient: FileClient,
        date: @escaping () -> Date,
        uuid: @escaping () -> UUID,
        storeKitClient: StoreKitClient,
        shareSheetClient: ShareSheetClient,
        emailClient: EmailClient,
        cloudKitClient: CloudKitClient
    ) {
        self.uiApplicationClient = uiApplicationClient
        self.uiUserInterfaceClient = uiUserInterfaceClient
        self.bikeClient = bikeClient
        self.brandAPIClient = brandAPIClient
        self.componentClient = componentClient
        self.maintenanceClient = maintenanceClient
        self.mileageClient = mileageClient
        self.rideClient = rideClient
        self.userDefaults = userDefaults
        self.mainQueue = mainQueue
        self.fileClient = fileClient
        self.date = date
        self.uuid = uuid
        self.storeKitClient = storeKitClient
        self.shareSheetClient = shareSheetClient
        self.emailClient = emailClient
        self.cloudKitClient = cloudKitClient
    }
    
    public var uiApplicationClient: UIApplicationClient
    public var uiUserInterfaceClient: UIUserInterfaceStyleClient
    public var bikeClient: BikeClient
    public var brandAPIClient: BrandClient
    public var componentClient: ComponentClient
    public var maintenanceClient: MaintenanceClient
    public var mileageClient: MileageClient
    public var rideClient: RideClient
    public var userDefaults: UserDefaultsClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var fileClient: FileClient
    public var date: () -> Date
    public var uuid: () -> UUID
    public var storeKitClient: StoreKitClient
    public var shareSheetClient: ShareSheetClient
    public var emailClient: EmailClient
    public var cloudKitClient: CloudKitClient
}

public extension AppCoreEnvironment {
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
    
    #if DEBUG
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
    #endif
}
