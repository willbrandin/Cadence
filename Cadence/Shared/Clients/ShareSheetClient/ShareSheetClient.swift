//
//  ShareSheetClient.swift
//  Cadence
//
//  Created by William Brandin on 10/25/21.
//

import UIKit
import ComposableArchitecture

struct ShareSheetClient {
    var present: () -> Effect<Never, Never>
}

// TODO: - Should this just be a SwiftUI Hosted VC that is presented?
extension ShareSheetClient {
    static var live: Self = Self(
        present: {
            .fireAndForget {
                let keyWindow = UIApplication.shared.connectedScenes
                            .first(where: { $0 is UIWindowScene })
                            .flatMap({ $0 as? UIWindowScene })?.keyWindow
                
                // TODO: - Change to App Store Listing
                guard let urlShare = URL(string: "https://developer.apple.com/xcode/swiftui/") else { return }
                let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)

                keyWindow?.rootViewController?.presentedViewController?.present(activityVC, animated: true, completion: nil)
            }
        }
    )
}

extension ShareSheetClient {
    static var noop: Self = Self(
        present: {
            return .none
        }
    )
}
