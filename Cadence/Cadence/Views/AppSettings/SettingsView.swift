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
import UIApplicationClient
import UIUserInterfaceStyleClient

struct UserSettings: Codable, Equatable {
    var colorScheme: ColorScheme
    var distanceUnit: DistanceUnit
    var appIcon: AppIcon?
}

typealias UserSettingsReducer = Reducer<SettingsState, SettingsAction, SettingsEnvironment>

struct SettingsState: Equatable {
        
    @BindableState var colorScheme: ColorScheme = .system
    @BindableState var appIcon: AppIcon?
    @BindableState var distanceUnit: DistanceUnit = .miles
    var supportsAlternativeIcon: Bool = true
    var isSyncWithiCloudOn = true
    @BindableState var isColorSchemeNavigationActive = false
    @BindableState var isUnitPickerNavigationActive = false
    @BindableState var isAppIconNavigationActive = false
    
    #if DEBUG
    @BindableState var isStoreJsonNavigationActive = false
    #endif
    
    var userSettings: UserSettings {
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

enum SettingsAction: BindableAction, Equatable {
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

struct SettingsEnvironment {
    var applicationClient: UIApplicationClient
    var uiUserInterfaceStyleClient: UIUserInterfaceStyleClient
    var fileClient: FileClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var userDefaults: UserDefaultsClient
    var mileageClient: MileageClient
    var storeKitClient: StoreKitClient
    var shareSheetClient: ShareSheetClient
    var emailClient: EmailClient
    var cloudKitClient: CloudKitClient
}

let userSettingsReducer = UserSettingsReducer
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

struct SettingsView: View {
    let store: Store<SettingsState, SettingsAction>
    @ObservedObject var viewStore: ViewStore<SettingsState, SettingsAction>
    
    init(
        store: Store<SettingsState, SettingsAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    var body: some View {
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
                NavigationLink(
                    isActive: viewStore.binding(\.$isStoreJsonNavigationActive),
                    destination: {
                        StoreJsonView()
                    }) {
                    HStack {
                        Image(systemName: "hammer")
                            .foregroundColor(.accentColor)
                        Text("Store Viewer")
                    }
                }
                
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


extension SettingsEnvironment {
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
