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
}

#if canImport(UIKit)
public extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
