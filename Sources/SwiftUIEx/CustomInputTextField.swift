//
//  CustomInputTextField.swift
//
//  Created by Ilya Belenkiy on 8/11/23.
//

import SwiftUI

@MainActor
public protocol CustomInputView: View {
    associatedtype Value
    func updateValue(_ value: Value?)
    func updateTypedText(_ text: String)
    func clear()
    func hide()
}

#if canImport(UIKit)

private class BasicTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

public struct CustomInputTextField<T, V: CustomInputView>: UIViewRepresentable where V.Value == T {
    @Binding var value: T?
    @Binding var typedText: String
    
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
    }

    public init(
        value: Binding<T?>,
        typedText: Binding<String>,
        configure: @escaping (UITextField) -> Void,
        inputView: @escaping () -> V
    ) {
        self._value = value
        self._typedText = typedText
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
    }
}

#endif

#if DEBUG && os(iOS)
private struct CustomInputTextFieldPreview: View {
    private struct Keyboard: CustomInputView {
        @Binding var value: String?
        @Binding var typedText: String

        func updateValue(_ value: String?) { self.value = value }
        func updateTypedText(_ text: String) { typedText = text }

        func clear() {
            value = nil
            typedText = ""
        }

        func hide() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        var body: some View {
            HStack {
                ForEach(["C", "F", "G"], id: \.self) { chord in
                    Button(chord) {
                        updateValue(chord)
                        updateTypedText(chord)
                    }
                }
                Button("Clear", action: clear)
                Button("Done", action: hide)
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }

    @State private var value: String?
    @State private var text = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Select a chord").font(.headline)
            CustomInputTextField(
                value: $value,
                typedText: $text,
                configure: {
                    $0.placeholder = "Tap to open the custom keyboard"
                    $0.borderStyle = .roundedRect
                },
                inputView: { Keyboard(value: $value, typedText: $text) }
            )
            .frame(height: 40)
            Text("Selection: \(value ?? "None")")
            Keyboard(value: $value, typedText: $text)
        }
        .padding()
        .frame(width: 360)
    }
}

@available(iOS 17.0, tvOS 17.0, *)
#Preview("Custom Input Text Field", traits: .sizeThatFitsLayout) {
    CustomInputTextFieldPreview()
}
#endif
