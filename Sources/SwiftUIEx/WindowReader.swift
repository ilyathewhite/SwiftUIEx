//
//  WindowReader.swift
//  
//
//  Created by Ilya Belenkiy on 8/6/23.
//

import SwiftUI

#if canImport(UIKit)

public struct WindowReader: UIViewRepresentable {
    @Binding var window: UIWindow?
    
    class WindowReaderView: UIView {
        var coordinator: Coordinator
        
        init(coordinator: Coordinator) {
            self.coordinator = coordinator
            super.init(frame: .zero)
        }
        
        override func didMoveToWindow() {
            coordinator.didMoveToWindow(window)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    @MainActor
    public class Coordinator {
        let parent: WindowReader
        
        init(parent: WindowReader) {
            self.parent = parent
        }
        
        func didMoveToWindow(_ window: UIWindow?) {
            parent.window = window
        }
    }
    
    public init(window: Binding<UIWindow?>) {
        self._window = window
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIView(context: Context) -> UIView {
        WindowReaderView(coordinator: context.coordinator)
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
    }
}

#endif

#if DEBUG && canImport(UIKit)
private struct WindowReaderPreview: View {
    @State private var window: UIWindow?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "macwindow").font(.largeTitle)
            Text(window == nil ? "Waiting for a window" : "Window connected")
        }
        .padding()
        .background(WindowReader(window: $window))
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Window Reader", traits: .sizeThatFitsLayout) {
    WindowReaderPreview()
}
#endif
