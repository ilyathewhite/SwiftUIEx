//
//  HammerEx.swift
//
//  Created by Ilya Belenkiy on 1/16/24.
//

import SwiftUI

#if os(iOS)

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

public extension View {
    func testIdentifier(_ id: String) -> some View {
#if DEBUG
        self.background(TestView(testIdentifier: id))
#else
        self
#endif
    }
}

#endif
