//
//  ActionTrigger.swift
//
//  Created by Ilya Belenkiy on 4/17/23.
//

import SwiftUI

public struct ActionTrigger: Equatable {
    var counter = 0
    
    public init() {}

    public mutating func fire() {
        counter += 1
    }
    
    public static func == (lhs: ActionTrigger, rhs: ActionTrigger) -> Bool {
        lhs.counter == rhs.counter
    }
}

public struct ActionTriggerModifier: ViewModifier {
    @Binding var trigger: ActionTrigger
    let action: () -> Void
    
    public init(_ trigger: Binding<ActionTrigger>, action: @escaping () -> Void) {
        _trigger = trigger
        self.action = action
    }
    
    public func body(content: Content) -> some View {
        content.onChange(of: trigger) { _ in action() }
    }
}

public extension View {
    func actionTrigger(_ trigger: Binding<ActionTrigger>, action: @escaping () -> Void) -> some View {
        modifier(ActionTriggerModifier(trigger, action: action))
    }
}
