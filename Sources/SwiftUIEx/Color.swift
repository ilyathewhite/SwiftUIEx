//
//  Color.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/26/21.
//

import SwiftUI
import FoundationEx

#if canImport(UIKit)
import UIKit
#endif

public extension Color {
    init(hex: String) {
        guard let (red, green, blue, alpha) = try? hex.parseAsHexColor() else {
            assertionFailure()
            self = .clear
            return
        }
        self.init(R: red, G: green, B: blue, darkR: 1.0 - red, darkG: 1.0 - green, darkB: 1.0 - blue, alpha: alpha)
    }
    
    init(R: Double, G: Double, B: Double, darkR: Double, darkG: Double, darkB: Double, alpha: Double = 1) {
#if canImport(UIKit)
        let uiColor = UIColor(dynamicProvider: {
            switch $0.userInterfaceStyle {
            case .dark:
                return UIColor(red: darkR, green: darkG, blue: darkB, alpha: alpha)
            default:
                return UIColor(red: R, green: G, blue: B, alpha: alpha)
            }
        })
        self.init(uiColor)
#else
        let nsColor = NSColor(name: nil, dynamicProvider: {
            let isDarkMode = $0.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            if isDarkMode {
                return NSColor(red: darkR, green: darkG, blue: darkB, alpha: alpha)
            }
            else {
                return NSColor(red: R, green: G, blue: B, alpha: alpha)
            }
        })
        self.init(nsColor)
#endif
    }
    
    init(R: Int, G: Int, B: Int, darkR: Int, darkG: Int, darkB: Int, alpha: Double = 1) {
        self.init(
            R: Double(R)/255, G: Double(G)/255, B: Double(B)/255,
            darkR: Double(darkR)/255, darkG: Double(darkG)/255, darkB: Double(darkB)/255,
            alpha: alpha
        )
    }
    
    #if os(iOS)

    static var systemGray2: Self { .init(uiColor: .systemGray2) }
    static var systemGray3: Self { .init(uiColor: .systemGray3) }
    static var systemGray4: Self { .init(uiColor: .systemGray4) }
    static var systemGray5: Self { .init(uiColor: .systemGray5) }
    static var systemGray6: Self { .init(uiColor: .systemGray6) }

    static var label: Self { .init(uiColor: .label) }
    static var secondaryLabel: Self { .init(uiColor: .secondaryLabel) }
    static var tertiaryLabel: Self { .init(uiColor: .tertiaryLabel) }
    static var quaternaryLabel: Self { .init(uiColor: .quaternaryLabel) }
    static var placeholderText: Self { .init(uiColor: .placeholderText) }

    static var systemFill: Self { .init(uiColor: .systemFill) }
    static var secondarySystemFill: Self { .init(uiColor: .secondarySystemFill) }
    static var tetriarySystemFill: Self { .init(uiColor: .tertiarySystemFill) }
    static var quaternarySystemFill: Self { .init(uiColor: .quaternarySystemFill) }

    static var systemBackground: Self { .init(uiColor: .systemBackground) }
    static var secondarySystemBackground: Self { .init(uiColor: .secondarySystemBackground) }
    static var tertiarySystemBackground: Self { .init(uiColor: .tertiarySystemBackground) }
    
    #endif

    #if os(macOS)
    static var label: Self { .init(nsColor: .labelColor) }
    static var secondaryLabel: Self { .init(nsColor: .secondaryLabelColor) }
    static var tertiaryLabel: Self { .init(nsColor: .tertiaryLabelColor) }
    static var quaternaryLabel: Self { .init(nsColor: .quaternaryLabelColor) }
    
    // the values are from
    // https://developer.apple.com/design/human-interface-guidelines/color
    
    static var systemGray2: Self { .init(R: 174, G: 174, B: 178, darkR: 99, darkG: 99, darkB: 102) }
    static var systemGray3: Self { .init(R: 199, G: 199, B: 204, darkR: 72, darkG: 72, darkB: 74) }
    static var systemGray4: Self { .init(R: 209, G: 209, B: 214, darkR: 58, darkG: 58, darkB: 60) }
    static var systemGray5: Self { .init(R: 229, G: 229, B: 234, darkR: 44, darkG: 44, darkB: 46) }
    
    static var systemBackground: Self { .init(R: 255, G: 255, B: 255, darkR: 0, darkG: 0, darkB: 0) }

    #endif
}
