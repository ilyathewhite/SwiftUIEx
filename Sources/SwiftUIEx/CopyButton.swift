//
//  CopyButton.swift
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

public struct CopyButton<T: TransferableEx>: View {
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
#if os(macOS)
        let pboard = NSPasteboard.general
        pboard.clearContents()
        pboard.writeObjects([value.pasteboardItem])
#else
        let pboard = UIPasteboard.general
        let item = NSItemProvider()
        item.register(value)
        pboard.setItemProviders([item], localOnly: false, expirationDate: nil)
#endif
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
