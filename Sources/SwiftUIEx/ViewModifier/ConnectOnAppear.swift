//
//  ConnectOnAppear.swift
//
//  Created by Ilya Belenkiy on 10/2/23.
//

import SwiftUI

public struct ConnectOnAppear: ViewModifier {
    public let connectIfHidden: Bool
    public let connect: () -> Void

    @Environment(\.isHidden) var isHidden
    @State private var isConnected = false

    public func body(content: Content) -> some View {
        content
            .onAppear {
                guard !isConnected else { return }
                guard !isHidden || connectIfHidden else { return }
                connect()
                isConnected = true
            }
    }
}

public extension View {
    func connectOnAppear(connectIfHidden: Bool = false, connect: @escaping () -> Void) -> some View {
        modifier(ConnectOnAppear(connectIfHidden: connectIfHidden, connect: connect))
    }
}

#if DEBUG
private struct ConnectOnAppearPreview: View {
    @State private var connected = false
    @State private var identity = 0

    var body: some View {
        VStack(spacing: 16) {
            Label(connected ? "Connected" : "Waiting", systemImage: connected ? "checkmark.circle" : "clock")
                .connectOnAppear { connected = true }
                .id(identity)
            Button("Reconnect") {
                connected = false
                identity += 1
            }
        }
        .padding()
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Connect On Appear", traits: .sizeThatFitsLayout) {
    ConnectOnAppearPreview()
}
#endif
