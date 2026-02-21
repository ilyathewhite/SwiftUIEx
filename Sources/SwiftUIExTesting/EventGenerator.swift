#if os(iOS)
import Foundation
import Hammer
import SwiftUI
import UIKit

public extension EventGenerator {
    @MainActor
    convenience init<Content: View>(
        view: Content,
        accessibilityDelay: TimeInterval = 0.11
    ) async throws {
        let window = try firstSceneWindow()
        window.rootViewController = UIHostingController(rootView: view)
        window.makeKeyAndVisible()
        try self.init(window: window)
        if accessibilityDelay > 0 {
            try await Task.sleep(for: .seconds(accessibilityDelay))
        }
    }
}
#endif
