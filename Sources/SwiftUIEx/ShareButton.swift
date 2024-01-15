//
//  ShareButton.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 9/25/22.
//

import SwiftUI

public protocol TransferableEx: Transferable {
    associatedtype Preview: Transferable
#if os(macOS)
    var pasteboardItem: NSPasteboardItem { get }
#endif
    var exportPreview: SharePreview<Never, Preview> { get }
}

#if os(iOS)
public struct ShareOrCopyButton<T: TransferableEx>: View {
    public let value: T?
    
    public init(_ value: T?) {
        self.value = value
    }

    public var body: some View {
        if let value {
            ShareLink(item: value, preview: value.exportPreview) {
                Image(systemName: "square.and.arrow.up")
            }
        }
        else {
            ShareLink(item: "")
                .disabled(true)
        }
    }
}
#endif

#if os(macOS)
public struct ShareOrCopyButton<T: TransferableEx>: View {
    let value: T?
    
    @State private var didCopy = false
    
    var icon: String {
        didCopy ? "checkmark" : "square.on.square"
    }
    
    public init(_ value: T?) {
        self.value = value
    }
    
    func copy() {
        guard let value else { return }
        let pboard = NSPasteboard.general
        pboard.clearContents()
        pboard.writeObjects([value.pasteboardItem])
        didCopy = true
        Task {
            try? await Task.sleep(for: .seconds(0.75))
            didCopy = false
        }
    }
    
    public var body: some View {
        Button(action: copy) {
            Image(systemName: icon)
                .padding()
                .contentShape(Rectangle())
        }
        .disabled(value == nil)
        .buttonStyle(.borderless)
    }
}
#endif
