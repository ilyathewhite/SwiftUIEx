//
//  TestKit.swift
//  SwiftUIEx
//
//  Created by Ilya Belenkiy on 2/16/26.
//

import Foundation

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

    public enum TestingError: Error, Equatable, LocalizedError {
        case missingFirstSceneWindow
        case missingWindow
        case missingViewWithAccessibilityIdentifier(String)
        case failedToCreateMouseEvent(String)
        case failedToDeliverEvent(String)
        case notImplemented(String)

        public var errorDescription: String? {
            switch self {
            case .missingFirstSceneWindow:
                return "Unable to find the first scene window."
            case .missingWindow:
                return "Unable to find a test window."
            case let .missingViewWithAccessibilityIdentifier(identifier):
                return "Unable to find a view with accessibility identifier '\(identifier)'."
            case let .failedToCreateMouseEvent(eventType):
                return "Unable to create a mouse event for '\(eventType)'."
            case let .failedToDeliverEvent(eventType):
                return "Unable to deliver the '\(eventType)' event."
            case let .notImplemented(feature):
                return "'\(feature)' is not implemented on this platform."
            }
        }
    }
}
