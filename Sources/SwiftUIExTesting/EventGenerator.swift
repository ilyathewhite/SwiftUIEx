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
import CoreGraphics
import Hammer
import UIKit

public typealias FingerIndex = Hammer.FingerIndex
public typealias HammerLocatable = Hammer.HammerLocatable
public typealias RelativeLocation = Hammer.RelativeLocation

public extension EventGenerator {
    func viewWithIdentifier(_ accessibilityIdentifier: String) throws -> UIView {
        try backend.viewWithIdentifier(accessibilityIdentifier)
    }

    func viewWithAccessibilityLabel(_ label: String) throws -> UIView {
        try backend.viewWithAccessibilityLabel(label)
    }

    func keyType(_ text: String, interval: TimeInterval = Hammer.EventGenerator.keyTypeInterval) throws {
        try backend.keyType(text, interval: interval)
    }

    func fingerTap(
        _ index: FingerIndex? = .automatic,
        at location: HammerLocatable? = nil,
        numberOfTimes tapCount: Int = 1,
        interval: TimeInterval = Hammer.EventGenerator.multiTapInterval
    ) throws {
        try backend.fingerTap(index, at: location, numberOfTimes: tapCount, interval: interval)
    }

    func fingerDown(_ index: FingerIndex? = .automatic, at location: HammerLocatable? = nil) throws {
        try backend.fingerDown(index, at: location)
    }

    func fingerMove(
        _ indices: [FingerIndex?] = .automatic,
        translationX x: CGFloat,
        y: CGFloat,
        duration: TimeInterval
    ) throws {
        try backend.fingerMove(indices, translationX: x, y: y, duration: duration)
    }

    func fingerUp(_ index: FingerIndex?) throws {
        try backend.fingerUp(index)
    }

    func fingerDrag(
        _ index: FingerIndex? = .automatic,
        from startPoint: HammerLocatable,
        to endPoint: HammerLocatable,
        duration: TimeInterval
    ) throws {
        try backend.fingerDrag(index, from: startPoint, to: endPoint, duration: duration)
    }
}

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

    func viewWithIdentifier(_ accessibilityIdentifier: String) throws -> UIView {
        do {
            return try eventGenerator.viewWithIdentifier(accessibilityIdentifier)
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

    func viewWithAccessibilityLabel(_ label: String) throws -> UIView {
        try SwiftUIExTesting.viewWithAccessibilityLabel(label, in: eventGenerator.window)
    }

    func keyType(_ text: String, interval: TimeInterval) throws {
        try eventGenerator.keyType(text, interval: interval)
    }

    func fingerTap(
        _ index: FingerIndex?,
        at location: HammerLocatable?,
        numberOfTimes tapCount: Int,
        interval: TimeInterval
    ) throws {
        try eventGenerator.fingerTap(index, at: location, numberOfTimes: tapCount, interval: interval)
    }

    func fingerDown(_ index: FingerIndex?, at location: HammerLocatable?) throws {
        try eventGenerator.fingerDown(index, at: location)
    }

    func fingerMove(_ indices: [FingerIndex?], translationX x: CGFloat, y: CGFloat, duration: TimeInterval) throws {
        try eventGenerator.fingerMove(indices, translationX: x, y: y, duration: duration)
    }

    func fingerUp(_ index: FingerIndex?) throws {
        try eventGenerator.fingerUp(index)
    }

    func fingerDrag(
        _ index: FingerIndex?,
        from startPoint: HammerLocatable,
        to endPoint: HammerLocatable,
        duration: TimeInterval
    ) throws {
        try eventGenerator.fingerDrag(index, from: startPoint, to: endPoint, duration: duration)
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
