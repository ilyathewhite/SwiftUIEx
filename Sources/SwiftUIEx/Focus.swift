//
//  Focus.swift
//
//  Created by Ilya Belenkiy on 1/15/24.
//

import SwiftUI

#if os(macOS)

struct FocusableContainerHidingRing<V: View>: NSViewRepresentable {
    let content: V
    
    var wrappedContent: AnyView {
        AnyView(content.focusable())
    }

    public func makeNSView(context: Context) -> NSHostingView<AnyView> {
        let view = NSHostingView(rootView: wrappedContent)
        view.focusRingType = .none
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    public func updateNSView(_ nsView: NSHostingView<AnyView>, context: Context) {
        nsView.rootView = wrappedContent
    }
}

public extension View {
    func focusableHidingRing() -> some View {
        FocusableContainerHidingRing(content: self)
    }
}

#endif

private struct AncestorIsFocusedKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    var ancestorIsFocused: Bool {
        get { self[AncestorIsFocusedKey.self] }
        set { self[AncestorIsFocusedKey.self] = newValue }
    }
}

public extension View {
    // focused() does the same thing, but it doesn't always work with focusableHidingRing(). Both focusableHidingRing
    // and ancestorIsFocused should be removed when SwiftUIEx drops support for macOS 13.
    func focusedEx(_ condition: FocusState<Bool>.Binding) -> some View {
        self.environment(\.ancestorIsFocused, condition.wrappedValue)
            .focused(condition)
    }
}
