//
//  StyledTextField.swift
//
//  Created by Ilya Belenkiy on 8/11/23.
//

import SwiftUI
#if os(iOS)
public typealias OSFont = UIFont
#else
public typealias OSFont = NSFont
#endif

#if os(iOS)

public struct StyledTextField: UIViewRepresentable {
    @Binding var text: String
    var hasFocus: FocusState<Bool>.Binding
    let configure: (UITextField) -> Void
    let formatter: Formatter?

    // Returns the value represented by the input string. If the formatter cannot create a value from the input,
    // the callback is called with nil.
    let getValue: ((AnyObject?) -> Void)?
    
    @Environment(\.foregroundColor) var foregroundColor

    public class Coordinator: NSObject, UITextFieldDelegate {
        let parent: StyledTextField
        
        init(parent: StyledTextField) {
            self.parent = parent
        }
        
        public func textFieldShouldClear(_ textField: UITextField) -> Bool {
            parent.text.removeAll()
            return true
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let text = textField.text ?? ""
            guard let strRange = Range(range, in: text) else { return false }
            let newText = text.replacingCharacters(in: strRange, with: string)
            if let formatter = parent.formatter {
                var replacementText: NSString?
                formatter.isPartialStringValid(newText, newEditingString: &replacementText, errorDescription: nil)
                parent.text = replacementText as? String ?? text
            }
            else {
                parent.text = newText
            }
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            if let text = textField.text, let formatter = parent.formatter, let getValue = parent.getValue {
                var value: AnyObject? = nil
                formatter.getObjectValue(&value, for: text, errorDescription: nil)
                if let value, !(value is NSNull) {
                    getValue(value)
                }
                else {
                    getValue(nil)
                }
                // workaround for mac catalyst; the caller must end focus
                return false
            }
            else {
                return true
            }
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.hasFocus.wrappedValue = true
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            parent.hasFocus.wrappedValue = false
        }
    }

    public init(
        text: Binding<String>,
        hasFocus: FocusState<Bool>.Binding,
        formatter: Formatter? = nil,
        getValue: ((AnyObject?) -> Void)? = nil,
        configure: @escaping (UITextField) -> Void
    ) {
        self._text = text
        self.hasFocus = hasFocus
        self.formatter = formatter
        self.getValue = getValue
        self.configure = configure
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    public func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        
        // default settings
        textField.delegate = context.coordinator
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.clearButtonMode = .whileEditing
        
        configure(textField)

        return textField
    }
    
    public func updateUIView(_ textField: UITextField, context: Context) {
        if textField.text != text {
            textField.text = text
        }
        textField.textColor = .init(foregroundColor)
        
        // Don't resign first responder. This breaks the responder chain in SwiftUI and, as one of the side effects,
        // breaks keyboard shortcuts.
        
        if hasFocus.wrappedValue && !textField.isFirstResponder {
            textField.becomeFirstResponder()
        }
    }
}

#else

public struct StyledTextField: NSViewRepresentable {
    @Binding var text: String
    var hasFocus: FocusState<Bool>.Binding
    @Binding var windowIsKey: Bool
    let configure: (NSTextField) -> Void
    let formatter: Formatter?

    // Returns the value represented by the input string. If the formatter cannot create a value from the input,
    // the callback is called with nil.
    let getValue: ((AnyObject?) -> Void)?
    
    @Environment(\.foregroundColor) var foregroundColor

    public class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: StyledTextField
        weak var window: NSWindow?
        
        init(parent: StyledTextField) {
            self.parent = parent
        }
        
        public func controlTextDidChange(_ obj: Notification) {
            guard let fieldEditor = obj.userInfo?["NSFieldEditor"] as? NSTextView else { return }
            let text = fieldEditor.string
            if let formatter = parent.formatter {
                var replacementText: NSString?
                formatter.isPartialStringValid(text, newEditingString: &replacementText, errorDescription: nil)
                fieldEditor.string =  replacementText as? String ?? text
            }
            parent.text = fieldEditor.string
        }
        
        public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
            if let formatter = parent.formatter, let getValue = parent.getValue {
                var value: AnyObject? = nil
                formatter.getObjectValue(&value, for: fieldEditor.string, errorDescription: nil)
                if let value, !(value is NSNull) {
                    getValue(value)
                    return true
                }
                else {
                    getValue(nil)
                    return false
                }
            }
            else {
                return true
            }
        }

        public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            switch commandSelector {
            case #selector(NSStandardKeyBindingResponding.cancelOperation(_:)):
                if textView.string.isEmpty {
                    control.endEditing(textView)
                }
                else {
                    parent.text = ""
                    textView.string = ""
                }
                return true
            case #selector(NSStandardKeyBindingResponding.insertNewline(_:)):
                if self.control(control, textShouldEndEditing: textView) {
                    control.endEditing(textView)
                }
                return true
            default:
                return false
            }
        }
    }

    public init(
        text: Binding<String>,
        hasFocus: FocusState<Bool>.Binding,
        windowIsKey: Binding<Bool>,
        formatter: Formatter? = nil,
        getValue: ((AnyObject?) -> Void)? = nil,
        configure: @escaping (NSTextField) -> Void
    ) {
        self._text = text
        self.hasFocus = hasFocus
        self._windowIsKey = windowIsKey
        self.formatter = formatter
        self.getValue = getValue
        self.configure = configure
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    public func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        
        // default settings
        textField.delegate = context.coordinator
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        configure(textField)

        return textField
    }
    
    public func updateNSView(_ textField: NSTextField, context: Context) {
        if (context.coordinator.window == nil) && (textField.window != nil) {
            context.coordinator.window = textField.window
            if (textField.window?.isKeyWindow ?? false) {
                DispatchQueue.main.async {
                    context.coordinator.parent.windowIsKey = true
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: NSWindow.didBecomeKeyNotification,
                object: textField.window,
                queue: .main,
                using: { _ in
                    context.coordinator.parent.windowIsKey = true
                }
            )
            
            NotificationCenter.default.addObserver(
                forName: NSWindow.didResignKeyNotification,
                object: textField.window,
                queue: .main,
                using: { _ in
                    context.coordinator.parent.windowIsKey = false
                }
            )
        }
        
        if textField.stringValue != text {
            textField.stringValue = text
        }
        textField.textColor = .init(foregroundColor)
        
        // Don't resign first responder. This breaks the responder chain in SwiftUI and, as one of the side effects,
        // breaks keyboard shortcuts.
        
        guard hasFocus.wrappedValue else { return }
        if !isInResponderChain(textField, chainStart:  textField.window?.firstResponder) {
            textField.becomeFirstResponder()
        }
    }
}

private func isInResponderChain(_ responder: NSResponder, chainStart: NSResponder?) -> Bool {
    guard let chainStart else { return false }
    return responder == chainStart ? true : isInResponderChain(responder, chainStart: chainStart.nextResponder)
}

#endif
