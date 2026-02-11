//
//  OnAppearEx.swift
//
//  Created by Ilya Belenkiy on 10/2/23.
//

import SwiftUI

public struct OnAppearEx: ViewModifier {
    public let isConnected: () -> Bool
    public let action: () -> Void
    
    @State private var pendingOnAppearCount = 0

    public func body(content: Content) -> some View {
        content
            .onAppear {
                guard isConnected() else {
                    pendingOnAppearCount += 1
                    return
                }
                action()
                pendingOnAppearCount = 0
            }
            .onChange(of: pendingOnAppearCount) { count in
                guard count > 0 else { return }
                if isConnected() {
                    action()
                    pendingOnAppearCount = 0
                }
                else {
                    DispatchQueue.main.async {
                        pendingOnAppearCount += 1
                    }
                }
            }
    }
}

public extension View {
    func onAppear(isConnected: @escaping () -> Bool, action: @escaping () -> Void) -> some View {
        modifier(OnAppearEx(isConnected: isConnected, action: action))
    }
}
