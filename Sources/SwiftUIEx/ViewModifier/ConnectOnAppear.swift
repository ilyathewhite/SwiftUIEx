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
