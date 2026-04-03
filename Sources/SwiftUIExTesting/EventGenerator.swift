import Foundation
import SwiftUI

@MainActor
public final class EventGenerator {
    private let backend: PlatformEventGenerator

    public init<Content: View>(
        view: Content,
        accessibilityDelay: TimeInterval = 0.11
    ) async throws {
        self.backend = try await PlatformEventGenerator(
            view: view,
            accessibilityDelay: accessibilityDelay
        )
    }

    public func fingerTap(at accessibilityIdentifier: String) throws {
        try backend.fingerTap(at: accessibilityIdentifier)
    }
}

#if os(iOS)
import Hammer
import UIKit

@MainActor
private final class PlatformEventGenerator {
    private let eventGenerator: Hammer.EventGenerator
    private let hostingController: UIHostingController<AnyView>
    private let window: UIWindow?

    init<Content: View>(
        view: Content,
        accessibilityDelay: TimeInterval
    ) async throws {
        let hostingController = UIHostingController(rootView: AnyView(view))
        self.hostingController = hostingController
        if let window = firstSceneWindow() {
            window.rootViewController = hostingController
            window.makeKeyAndVisible()
            self.window = window
            self.eventGenerator = try Hammer.EventGenerator(window: window)
        } else {
            self.window = nil
            self.eventGenerator = try Hammer.EventGenerator(viewController: hostingController)
        }

        if accessibilityDelay > 0 {
            try await Task.sleep(for: .seconds(accessibilityDelay))
        }
    }

    func fingerTap(at accessibilityIdentifier: String) throws {
        do {
            try eventGenerator.fingerTap(at: accessibilityIdentifier)
        }
        catch let error as HammerError {
            switch error {
            case .unableToFindView(let identifier):
                throw TestKit.TestingError.missingViewWithAccessibilityIdentifier(identifier)
            default:
                throw error
            }
        }
    }
}

#elseif os(macOS)
/*
 macOS event injection is intentionally disabled for now.

 Investigation notes from 2026-03-29:
 - NSEvent.mouseEvent(...) + NSApp.sendEvent(...) reached local event monitors
   and NSWindow.sendEvent(...), and it was sufficient to activate Button-based
   controls.
 - The same path never reached NSView.mouseDown/mouseUp and never triggered
   SwiftUI .onTapGesture, even when hit-testing found the expected hosted view.
 - The failure reproduced inside the native ContainerMac host app, so it was
   not limited to the package-test harness.
 - We tried distinct timestamps, non-zero monotonic eventNumber values, matched
   clickCount values, hover priming with mouseMoved, queued postEvent delivery,
   real CGEvent posting (postToPid / cghid / session / annotated session),
   private NSWindow routing, and IOHID dispatch. None reached NSView.mouseDown,
   and several regressed the previously working Button path.

 Revisit from here only after finding a delivery path that reliably reaches
 NSView.mouseDown on macOS.
 */
@MainActor
private final class PlatformEventGenerator {
    private static let featureName = "EventGenerator on macOS"

    init<Content: View>(
        view: Content,
        accessibilityDelay: TimeInterval
    ) async throws {
        _ = view
        _ = accessibilityDelay
        throw TestKit.TestingError.notImplemented(Self.featureName)
    }

    func fingerTap(at accessibilityIdentifier: String) throws {
        _ = accessibilityIdentifier
        throw TestKit.TestingError.notImplemented(Self.featureName)
    }
}

#else
@MainActor
private final class PlatformEventGenerator {
    private static let featureName = "EventGenerator on this platform"

    init<Content: View>(
        view: Content,
        accessibilityDelay: TimeInterval
    ) async throws {
        _ = view
        _ = accessibilityDelay
        throw TestKit.TestingError.notImplemented(Self.featureName)
    }

    func fingerTap(at accessibilityIdentifier: String) throws {
        _ = accessibilityIdentifier
        throw TestKit.TestingError.notImplemented(Self.featureName)
    }
}
#endif
