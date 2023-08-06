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
