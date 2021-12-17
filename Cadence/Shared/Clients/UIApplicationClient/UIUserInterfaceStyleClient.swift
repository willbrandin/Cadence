import UIKit
import ComposableArchitecture

struct UIUserInterfaceStyleClient {
    var setUserInterfaceStyle: (UIUserInterfaceStyle) -> Effect<Never, Never>
    var getUserInterfaceStyle: () -> Effect<UIUserInterfaceStyle, Never>
}

extension UIUserInterfaceStyleClient {
    static let noop = Self(
        setUserInterfaceStyle: { _ in .none },
        getUserInterfaceStyle: { .none }
    )
    
    static let live = Self(
        setUserInterfaceStyle: { userInterfaceStyle in
                .fireAndForget {
                    setUserInterfaceStyle(userInterfaceStyle)
                }
        },
        getUserInterfaceStyle: {
            let style = UITraitCollection.current.userInterfaceStyle
            return Effect(value: style)
        }
    )
    
    static let failing = Self(
        setUserInterfaceStyle: { _ in
            .failing("UIUserInterfaceStyleClient.setUserInterfaceStyle")
        },
        getUserInterfaceStyle: {
            .failing("UIUserInterfaceStyleClient.getUserInterfaceStyle")
        }
    )
    
    static func setUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        let windows = UIApplication.shared.connectedScenes
                    .first(where: { $0 is UIWindowScene })
                    .flatMap({ $0 as? UIWindowScene })?.windows
        
        windows?.forEach {
            $0.overrideUserInterfaceStyle = style
        }
    }
}
