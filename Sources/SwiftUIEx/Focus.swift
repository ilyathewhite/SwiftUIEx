//
//  File.swift
//  
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
