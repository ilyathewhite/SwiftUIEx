//
//  HammerEx.swift
//
//  Created by Ilya Belenkiy on 1/16/24.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)

public class PassthroughView: UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

public struct TestView: UIViewRepresentable {
    let testIdentifier: String

    public func makeUIView(context: Context) -> PassthroughView {
        let view = PassthroughView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = testIdentifier
        return view
    }

    public func updateUIView(_ uiView: PassthroughView, context: Context) {
    }
}

#elseif canImport(AppKit)

public class PassthroughView: NSView {
    public override func hitTest(_ point: NSPoint) -> NSView? {
        let view = super.hitTest(point)
        return view == self ? nil : view
    }
}

public struct TestView: NSViewRepresentable {
    let testIdentifier: String

    public func makeNSView(context: Context) -> PassthroughView {
        let view = PassthroughView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setAccessibilityIdentifier(testIdentifier)
        return view
    }

    public func updateNSView(_ nsView: PassthroughView, context: Context) {
    }
}

#endif

public extension View {
    func testIdentifier(_ id: String) -> some View {
#if DEBUG
        self.background(TestView(testIdentifier: id))
#else
        self
#endif
    }
}

#if DEBUG
private struct TestViewPreview: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 16) {
            Button("Tap count: \(count)") { count += 1 }
                .padding()
                .testIdentifier("preview.button")
            Text("The test marker leaves the button interactive.")
                .font(.caption)
        }
        .padding()
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Test View", traits: .sizeThatFitsLayout) {
    TestViewPreview()
}
#endif
