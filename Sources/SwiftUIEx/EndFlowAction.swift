//
//  EndFlowAction.swift
//
//  Created by Ilya Belenkiy on 8/5/23.
//

import SwiftUI

public struct EndFlowAction {
    let action: () -> Void
    
    public func callAsFunction() {
        action()
    }
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
}

public struct EndFlowActionKey: EnvironmentKey {
    public static let defaultValue: EndFlowAction? = nil
}

public extension EnvironmentValues {
    var endFlowAction: EndFlowAction? {
        get { self[EndFlowActionKey.self] }
        set { self[EndFlowActionKey.self] = newValue }
    }
}
