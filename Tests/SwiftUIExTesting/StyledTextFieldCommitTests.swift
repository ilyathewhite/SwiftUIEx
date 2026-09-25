#if os(macOS)
import AppKit
import SwiftUI
import Testing

@testable import SwiftUIEx

@MainActor
@Suite(.serialized)
struct StyledTextFieldCommitTests {
    @Test(arguments: [false, true])
    func repeatedReturnWithoutEditingSubmitsEachTime(commitOnEndEditing: Bool) {
        var committedValues: [String] = []
        let field = StyledTextField(
            text: .constant("Am"),
            getValue: { committedValues.append($0 as? String ?? "") },
            commitOnEndEditing: commitOnEndEditing,
            configure: { _ in }
        )
        let coordinator = field.makeCoordinator()
        let textField = NSTextField()
        let fieldEditor = NSTextView()
        fieldEditor.string = "Am"

        // Refocusing without changing text does not send controlTextDidBeginEditing.
        for _ in 0..<2 {
            #expect(coordinator.control(
                textField,
                textView: fieldEditor,
                doCommandBy: #selector(NSStandardKeyBindingResponding.insertNewline(_:))
            ))
            #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))
        }

        #expect(committedValues == ["Am", "Am"])
    }

    @Test
    func returnOnlyFieldDoesNotSubmitOnFocusLoss() {
        var committedValues: [String] = []
        let field = StyledTextField(
            text: .constant("Am"),
            getValue: { committedValues.append($0 as? String ?? "") },
            commitOnEndEditing: false,
            configure: { _ in }
        )
        let coordinator = field.makeCoordinator()
        let textField = NSTextField()
        let fieldEditor = NSTextView()
        fieldEditor.string = "Am"

        #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))
        #expect(committedValues.isEmpty)

        #expect(coordinator.control(
            textField,
            textView: fieldEditor,
            doCommandBy: #selector(NSStandardKeyBindingResponding.insertNewline(_:))
        ))
        #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))
        #expect(committedValues == ["Am"])
    }

    @Test
    func returnThenFocusLossCommitsOnlyOnce() {
        var committedValues: [String] = []
        let field = StyledTextField(
            text: .constant("Am"),
            getValue: { committedValues.append($0 as? String ?? "") },
            configure: { _ in }
        )
        let coordinator = field.makeCoordinator()
        let textField = NSTextField()
        let fieldEditor = NSTextView()
        fieldEditor.string = "Am"

        #expect(coordinator.control(
            textField,
            textView: fieldEditor,
            doCommandBy: #selector(NSStandardKeyBindingResponding.insertNewline(_:))
        ))
        // The search removes focus after Return, so AppKit asks to end editing again.
        #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))

        #expect(committedValues == ["Am"])
    }

    @Test
    func newEditingSessionCanCommitTheSameText() {
        var committedValues: [String] = []
        let field = StyledTextField(
            text: .constant("Am"),
            getValue: { committedValues.append($0 as? String ?? "") },
            configure: { _ in }
        )
        let coordinator = field.makeCoordinator()
        let textField = NSTextField()
        let fieldEditor = NSTextView()
        fieldEditor.string = "Am"

        #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))
        (coordinator as NSTextFieldDelegate).controlTextDidBeginEditing?(
            .init(name: NSControl.textDidBeginEditingNotification, object: textField)
        )
        #expect(coordinator.control(textField, textShouldEndEditing: fieldEditor))

        #expect(committedValues == ["Am", "Am"])
    }
}
#endif
