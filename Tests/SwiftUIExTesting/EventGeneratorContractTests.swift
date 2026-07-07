import SwiftUI
import SwiftUIEx
import SwiftUIExTesting
import Testing

#if os(iOS)
import UIKit

private struct LabeledPlatformView: UIViewRepresentable {
    let label: String
    let identifier: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.accessibilityLabel = label
        view.accessibilityIdentifier = identifier
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.accessibilityLabel = label
        uiView.accessibilityIdentifier = identifier
    }
}
#endif

@MainActor
private final class TapRecorder {
    private(set) var tapCounts: [String: Int] = [:]

    func recordTap(_ identifier: String) {
        tapCounts[identifier, default: 0] += 1
    }

    func tapCount(for identifier: String) -> Int {
        tapCounts[identifier, default: 0]
    }
}

#if os(iOS)
@MainActor
private func supportsHostedTouchInjection() -> Bool {
    // Hammer's touch injection path needs a real application scene. Hostless
    // Swift package tests can still verify lookup/error contracts, but the
    // actual synthetic tap flow is exercised in app-hosted suites.
    !UIApplication.shared.connectedScenes.isEmpty
}
#endif

@MainActor
@Suite(.serialized)
struct EventGeneratorContractTests {
    #if os(iOS)
    @Test
    func fingerTapTriggersButtonAction() async throws {
        guard supportsHostedTouchInjection() else { return }

        let recorder = TapRecorder()
        let eventGenerator = try await EventGenerator(
            view: Button("Tap Me") {
                recorder.recordTap("tap.button")
            }
            .buttonStyle(.borderedProminent)
            .frame(width: 160, height: 80)
            .testIdentifier("tap.button")
        )

        try eventGenerator.fingerTap(at: "tap.button")

        #expect(recorder.tapCount(for: "tap.button") == 1)
    }

    @Test
    func fingerTapTargetsCorrectButtonInCrowdedLayout() async throws {
        guard supportsHostedTouchInjection() else { return }

        let recorder = TapRecorder()
        let eventGenerator = try await EventGenerator(
            view: HStack(spacing: 6) {
                Button("Left") {
                    recorder.recordTap("button.left")
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 72, height: 60)
                .testIdentifier("button.left")

                Button("Middle") {
                    recorder.recordTap("button.middle")
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 72, height: 60)
                .testIdentifier("button.middle")

                Button("Right") {
                    recorder.recordTap("button.right")
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 72, height: 60)
                .testIdentifier("button.right")
            }
            .padding(10)
            .frame(width: 260, height: 90)
        )

        try eventGenerator.fingerTap(at: "button.middle")
        try eventGenerator.fingerTap(at: "button.right")
        try eventGenerator.fingerTap(at: "button.left")

        #expect(recorder.tapCount(for: "button.left") == 1)
        #expect(recorder.tapCount(for: "button.middle") == 1)
        #expect(recorder.tapCount(for: "button.right") == 1)
    }

    @Test
    func missingIdentifierThrowsTestingError() async throws {
        let eventGenerator = try await EventGenerator(
            view: Text("Existing View")
                .testIdentifier("existing.view.identifier")
        )

        do {
            try eventGenerator.fingerTap(at: "missing.view.identifier")
            Issue.record("Expected a missing identifier error.")
        } catch let error as TestKit.TestingError {
            #expect(
                error == .missingViewWithAccessibilityIdentifier(
                    "missing.view.identifier"
                )
            )
        }
    }

    @Test
    func viewLookupsFindIdentifierAndLabel() async throws {
        let eventGenerator = try await EventGenerator(
            view: LabeledPlatformView(label: "lookup.label", identifier: "lookup.identifier")
        )

        _ = try eventGenerator.viewWithIdentifier("lookup.identifier")
        _ = try eventGenerator.viewWithAccessibilityLabel("lookup.label")
    }
    #elseif os(macOS)
    @Test
    func macOSEventGeneratorReportsNotImplemented() async throws {
        do {
            _ = try await EventGenerator(
                view: Text("macOS Event Generation Placeholder")
            )
            Issue.record("Expected EventGenerator to be unavailable on macOS.")
        } catch let error as TestKit.TestingError {
            #expect(error == .notImplemented("EventGenerator on macOS"))
        }
    }
    #endif
}
