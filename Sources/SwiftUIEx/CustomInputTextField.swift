//
//  CustomInputTextField.swift
//
//  Created by Ilya Belenkiy on 8/11/23.
//

import SwiftUI

public protocol CustomInputView: View {
    associatedtype Value
    func updateValue(_ value: Value?)
    func updateTypedText(_ text: String)
    func clear()
    func hide()
}

private class BasicTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

public struct CustomInputTextField<T, V: CustomInputView>: UIViewRepresentable where V.Value == T {
    @Binding var value: T?
    @Binding var typedText: String
    
    @Binding var hasFocus: Bool
    let configure: (UITextField) -> Void
    var inputView: () -> V
    
    @Environment(\.foregroundColor) var foregroundColor

    public class Coordinator: NSObject, UITextFieldDelegate {
        let parent: CustomInputTextField
        let inputVC: UIHostingController<V>
        
        init(parent: CustomInputTextField) {
            self.parent = parent
            self.inputVC = .init(rootView: parent.inputView())
        }
        
        public func textFieldShouldClear(_ textField: UITextField) -> Bool {
            inputVC.rootView.clear()
            return true
        }
        
        public func textFieldDidChangeSelection(_ textField: UITextField) {
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        
        public func textField(_ textField: UITextField, editMenuForCharactersIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
            return nil
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return false
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.hasFocus = true
        }
        
        public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
            parent.hasFocus = false
        }
    }

    public init(
        value: Binding<T?>,
        typedText: Binding<String>,
        hasFocus: Binding<Bool>,
        configure: @escaping (UITextField) -> Void,
        inputView: @escaping () -> V
    ) {
        self._value = value
        self._typedText = typedText
        self._hasFocus = hasFocus
        self.configure = configure
        self.inputView = inputView
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
    
    public func makeUIView(context: Context) -> UITextField {
        let textField = BasicTextField()
        
        textField.delegate = context.coordinator
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.autocapitalizationType = .none
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []
        
        configure(textField)

        let inputView = context.coordinator.inputVC.view!
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.inputView = inputView

        return textField
    }
    
    public func updateUIView(_ textField: UITextField, context: Context) {
        textField.text = typedText
        textField.textColor = .init(foregroundColor)
        context.coordinator.inputVC.rootView = inputView()

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
