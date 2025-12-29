//
//  Focus.swift
//
//  Created by Ilya Belenkiy on 1/15/24.
//

import SwiftUI

#if os(macOS)

public extension View {
    func focusableHidingRing() -> some View {
        self.focusable().focusEffectDisabled()
    }
}

#endif
