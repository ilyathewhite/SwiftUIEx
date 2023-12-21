//
//  StyledTextField.swift
//
//  Created by Ilya Belenkiy on 8/11/23.
//

#if canImport(UIKit)
import SwiftUI

public struct StyledTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var hasFocus: Bool
    let configure: (UITextField) -> Void
    
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
            parent.text = text.replacingCharacters(in: strRange, with: string)
            return true
        }
        
        public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            parent.hasFocus = false
            return true
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.hasFocus = true
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            parent.hasFocus = false
        }
    }

    public init(
        text: Binding<String>,
        hasFocus: Binding<Bool>,
        configure: @escaping (UITextField) -> Void
    ) {
        self._text = text
        self._hasFocus = hasFocus
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

        if !hasFocus {
            DispatchQueue.main.async {
                textField.resignFirstResponder()
            }
        }
        else if !textField.isFirstResponder {
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
            }
        }
    }
}

#endif
