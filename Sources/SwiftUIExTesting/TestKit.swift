//
//  TestKit.swift
//  SwiftUIEx
//
//  Created by Ilya Belenkiy on 2/16/26.
//

import Foundation
import UIKit

public enum TestKit {
    public enum AnimationType: String, Sendable {
        case present
        case dismiss
        case push
        case pop
        case swipe

        public var duration: Duration {
            switch self {
            case .present, .dismiss:
                return .seconds(1.0) // less than this may trigger failures
            case .push, .pop:
                return .seconds(1.0)
            case .swipe:
                return .seconds(1.0)
            }
        }
    }

    public enum WaitUntilError: Error, LocalizedError {
        case timedOut(description: String)

        public var errorDescription: String? {
            switch self {
            case let .timedOut(description):
                return "Timed out waiting for \(description)."
            }
        }
    }

    public enum TestingError: Error {
        case missingFirstSceneWindow
        case missingViewWithAccessibilityLabel(String)
    }
}
