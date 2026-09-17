//
//  View.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/8/21.
//

import SwiftUI

public extension View {
    func sideEffect(_ f: () -> Void) -> Self {
        f()
        return self
    }
    
    func topDivider() -> some View {
        overlay(alignment: .top) { Divider() }
    }
}

#if os(iOS)

public extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func isContextMenuVisible(window: UIWindow?) -> Bool {
        guard let window else { return false }
        for subview in window.subviews {
            if type(of: subview) == NSClassFromString("_UIContextMenuContainerView") {
                return true
            }
        }
        return false
    }
}

#endif

#if os(macOS)

public extension View {
    func windowTitle(_ title: String) -> some View {
        navigationTitle(title).environment(\.windowTitle, title)
    }
}

#endif

#if DEBUG
private struct ViewExtensionsPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Section above").padding()
            Text("Section with a top divider")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .topDivider()
        }
        .frame(width: 300)
        .padding()
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("View Extensions", traits: .sizeThatFitsLayout) {
    ViewExtensionsPreview()
}
#endif
