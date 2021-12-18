import AppSupportFeature
import CloudKitClient
import SwiftUI
import ComposableArchitecture
import ComposableHelpers
import FileClient
import EmailClient
import Models
import MileageClient
import UserDefaultsClient
import StoreKitClient
import ShareSheetClient
import SwiftUIHelpers
import UIApplicationClient
import UIUserInterfaceStyleClient

typealias UserSettingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>

public struct SettingsState: Equatable {
    public init(
        supportsAlternativeIcon: Bool = true,
        isSyncWithiCloudOn: Bool = true,
        colorScheme: ColorScheme = .system,
        appIcon: AppIcon? = nil,
        distanceUnit: DistanceUnit = .miles,
        isColorSchemeNavigationActive: Bool = false,
        isUnitPickerNavigationActive: Bool = false,
        isAppIconNavigationActive: Bool = false
    ) {
        self.supportsAlternativeIcon = supportsAlternativeIcon
        self.isSyncWithiCloudOn = isSyncWithiCloudOn
        self.colorScheme = colorScheme
        self.appIcon = appIcon
        self.distanceUnit = distanceUnit
        self.isColorSchemeNavigationActive = isColorSchemeNavigationActive
        self.isUnitPickerNavigationActive = isUnitPickerNavigationActive
        self.isAppIconNavigationActive = isAppIconNavigationActive
    }
    
    public var supportsAlternativeIcon: Bool = true
    public var isSyncWithiCloudOn = true
    @BindableState public var colorScheme: ColorScheme = .system
    @BindableState public var appIcon: AppIcon?
    @BindableState public var distanceUnit: DistanceUnit = .miles
    @BindableState public var isColorSchemeNavigationActive = false
    @BindableState public var isUnitPickerNavigationActive = false
    @BindableState public var isAppIconNavigationActive = false
    
    #if DEBUG
    @BindableState public var isStoreJsonNavigationActive = false
    #endif
    
    public var userSettings: UserSettings {
        get {
            return UserSettings(
                colorScheme: colorScheme,
                distanceUnit: distanceUnit,
                appIcon: appIcon
            )
        }
        set {
            self.colorScheme = newValue.colorScheme
            self.appIcon = newValue.appIcon
            self.distanceUnit = newValue.distanceUnit
        }
    }
}

public enum SettingsAction: BindableAction, Equatable {
    case binding(BindingAction<SettingsState>)
    case iCloudSyncToggled(isOn: Bool)
    case onAppear
    case didTapClose
    case helpAndSupportTapped
    case rateCadenceTapped
    case shareCadenceTapped
    
    #if DEBUG
    case clearCache
    #endif
}

public struct SettingsEnvironment {
    public init(
        applicationClient: UIApplicationClient,
        uiUserInterfaceStyleClient: UIUserInterfaceStyleClient,
        fileClient: FileClient,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        userDefaults: UserDefaultsClient,
        mileageClient: MileageClient,
        storeKitClient: StoreKitClient,
        shareSheetClient: ShareSheetClient,
        emailClient: EmailClient,
        cloudKitClient: CloudKitClient
    ) {
        self.applicationClient = applicationClient
        self.uiUserInterfaceStyleClient = uiUserInterfaceStyleClient
        self.fileClient = fileClient
        self.mainQueue = mainQueue
        self.userDefaults = userDefaults
        self.mileageClient = mileageClient
        self.storeKitClient = storeKitClient
        self.shareSheetClient = shareSheetClient
        self.emailClient = emailClient
        self.cloudKitClient = cloudKitClient
    }
    
    public var applicationClient: UIApplicationClient
    public var uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    public var fileClient: FileClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var userDefaults: UserDefaultsClient
    public var mileageClient: MileageClient
    public var storeKitClient: StoreKitClient
    public var shareSheetClient: ShareSheetClient
    public var emailClient: EmailClient
    public var cloudKitClient: CloudKitClient
}

public let userSettingsReducer = UserSettingsReducer
{ state, action, environment in
    switch action {
        
    #if DEBUG
    case .clearCache:
        return .concatenate(
            environment.userDefaults.clear()
                .fireAndForget(),
            environment.applicationClient.exit()
                .fireAndForget()
        )
        
    #endif
        
    case let .iCloudSyncToggled(isOn):
        state.isSyncWithiCloudOn = isOn
        return environment.cloudKitClient.setPersistantStore(isOn)
            .fireAndForget()
        
    case .binding(\.$colorScheme):
        return environment.uiUserInterfaceStyleClient.setUserInterfaceStyle(state.colorScheme.userInterfaceStyle)
            .fireAndForget()
        
    case .binding(\.$appIcon):
        return environment.applicationClient
            .setAlternateIconName(state.appIcon?.rawValue)
            .fireAndForget()
        
    case .onAppear:
        state.supportsAlternativeIcon = environment.applicationClient.supportsAlternateIcons()
        state.appIcon = environment.applicationClient.alternateIconName()
            .flatMap(AppIcon.init(rawValue:))
        state.isSyncWithiCloudOn = environment.cloudKitClient.isCloudSyncOn()
        
        return .none
        
    case .rateCadenceTapped:
        return environment.storeKitClient.requestReview()
            .fireAndForget()
        
    case .shareCadenceTapped:
        return environment.shareSheetClient.present()
            .fireAndForget()
        
    case .helpAndSupportTapped:
        return environment.emailClient.sendEmail()
            .fireAndForget()
        
    default:
        return .none
    }
}
.binding()
.onChange(of: \.userSettings) { userSettings, _, _, environment in
    struct SaveDebounceId: Hashable {}

    return environment.fileClient
        .saveUserSettings(userSettings: userSettings, on: environment.mainQueue)
        .fireAndForget()
        .debounce(id: SaveDebounceId(), for: .seconds(1), scheduler: environment.mainQueue)
}

public struct SettingsView: View {
    let store: Store<SettingsState, SettingsAction>
    @ObservedObject var viewStore: ViewStore<SettingsState, SettingsAction>
    
    public init(
        store: Store<SettingsState, SettingsAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        List {
            Section(
                footer:
                    Text("Syncing with iCloud will make sure your data is on all your devices.")
            ) {
                NavigationLink(isActive: viewStore.binding(\.$isUnitPickerNavigationActive).removeDuplicates()) {
                    DistanceUnitPickerView(distanceUnit: viewStore.binding(\.$distanceUnit))
                } label: {
                    HStack {
                        Image(systemName: "dial.max")
                            .foregroundColor(.accentColor)
                        Text("Units")
                        Spacer()
                        Text(viewStore.distanceUnit.title.capitalized)
                            .foregroundColor(.secondary)
                    }
                }
            
                NavigationLink(isActive: viewStore.binding(\.$isColorSchemeNavigationActive).removeDuplicates()) {
                    ColorSchemePickerView(colorScheme: viewStore.binding(\.$colorScheme))
                } label: {
                    HStack {
                        Image(systemName: "paintbrush.pointed")
                            .foregroundColor(.accentColor)
                        Text("Theme")
                        Spacer()
                        Text(viewStore.colorScheme.title)
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle(isOn: viewStore.binding(
                    get: \.isSyncWithiCloudOn,
                    send: SettingsAction.iCloudSyncToggled(isOn:)
                )) {
                    HStack {
                        Image(systemName: "icloud")
                            .foregroundColor(.accentColor)
                        Text("iCloud Sync")
                    }
                }
                
                if viewStore.supportsAlternativeIcon {
                    NavigationLink(isActive: viewStore.binding(\.$isAppIconNavigationActive).removeDuplicates()) {
                        AppIconPickerView(appIcon: viewStore.binding(\.$appIcon))
                    } label: {
                        HStack {
                            Image(systemName: "app")
                                .foregroundColor(.accentColor)
                            Text("App Icon")
                            Spacer()
                        }
                    }
                }
            }
            .textCase(nil)
            
            Section {
                Button(action: { viewStore.send(.helpAndSupportTapped) }) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.accentColor)
                        Text("Help and Support")
                            .foregroundColor(.primary)
                    }
                }
            }
            .textCase(nil)
            
            Section(header:
                Text("Support Cadence")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(.leading, -16)
            ) {
                Button("Rate Cadence on the App Store", action: { viewStore.send(.rateCadenceTapped) })
                Button("Recommend Cadence to a Friend", action: { viewStore.send(.shareCadenceTapped) })
            }
            .textCase(nil)
            
            Section {
                NavigationLink("Terms of Service", destination: TermsAndConditionsView())
                NavigationLink("Privacy", destination: PrivacyPolicyView())
            }
            .textCase(nil)
            
            #if DEBUG
            Section(header:
                Text("Developer Settings")
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                    .padding(.leading, -16)
            ) {
//                NavigationLink(
//                    isActive: viewStore.binding(\.$isStoreJsonNavigationActive),
//                    destination: {
//                        StoreJsonView()
//                    }) {
//                    HStack {
//                        Image(systemName: "hammer")
//                            .foregroundColor(.accentColor)
//                        Text("Store Viewer")
//                    }
//                }
//
                Button(action: { viewStore.send(.clearCache) }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear Cache")
                    }
                    .foregroundColor(.red)
                }
            }
            .textCase(nil)
            #endif
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewStore.send(.didTapClose) }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

struct AppSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView(
                store: Store(
                    initialState: SettingsState(),
                    reducer: userSettingsReducer,
                    environment: .mocked
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


public extension SettingsEnvironment {
    static var failing: Self {
        Self(
            applicationClient: .failing,
            uiUserInterfaceStyleClient: .failing,
            fileClient: .failing,
            mainQueue: .main,
            userDefaults: .failing,
            mileageClient: .failing,
            storeKitClient: .noop,
            shareSheetClient: .noop,
            emailClient: .noop,
            cloudKitClient: .noop
        )
    }
    
    static var mocked: Self {
        Self(
            applicationClient: .noop,
            uiUserInterfaceStyleClient: .noop,
            fileClient: .noop,
            mainQueue: .main,
            userDefaults: .noop,
            mileageClient: .noop,
            storeKitClient: .noop,
            shareSheetClient: .noop,
            emailClient: .noop,
            cloudKitClient: .noop
        )
    }
}
