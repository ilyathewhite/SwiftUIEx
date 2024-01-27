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
    }

    public init(
        text: Binding<String>,
        formatter: Formatter? = nil,
        getValue: ((AnyObject?) -> Void)? = nil,
        configure: @escaping (UITextField) -> Void
    ) {
        self._text = text
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
    }
}

#else

public struct StyledTextField: NSViewRepresentable {
    @Binding var text: String
    let configure: (NSTextField) -> Void
    let formatter: Formatter?

    // Returns the value represented by the input string. If the formatter cannot create a value from the input,
    // the callback is called with nil.
    let getValue: ((AnyObject?) -> Void)?
    
    @Environment(\.foregroundColor) var foregroundColor

    public class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: StyledTextField
        
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
                }
                else {
                    getValue(nil)
                }
            }
            return true
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
        formatter: Formatter? = nil,
        getValue: ((AnyObject?) -> Void)? = nil,
        configure: @escaping (NSTextField) -> Void
    ) {
        self._text = text
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
        if textField.stringValue != text {
            textField.stringValue = text
        }
        textField.textColor = .init(foregroundColor)
    }
}

#endif
