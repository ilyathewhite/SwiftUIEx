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

#if DEBUG
private struct OnAppearExPreview: View {
    @State private var connected = false
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 16) {
            Text(appeared ? "Appeared after connecting" : "Waiting for connection")
                .onAppear(isConnected: { connected }, action: { appeared = true })
            ProgressView().opacity(appeared ? 0 : 1)
        }
        .padding()
        .task {
            try? await Task.sleep(for: .milliseconds(300))
            connected = true
        }
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("On Appear Ex", traits: .sizeThatFitsLayout) {
    OnAppearExPreview()
}
#endif
