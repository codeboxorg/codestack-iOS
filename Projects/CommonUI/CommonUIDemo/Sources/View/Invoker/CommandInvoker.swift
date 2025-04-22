import UIKit
import Global

final class CommandInvoker {
    private weak var editor: UITextView?
    
    init(editor: UITextView? = nil, undoStack: [UndoableTextInputCommand], redoStack: [UndoableTextInputCommand]) {
        self.editor = editor
        self.undoStack = undoStack
        self.redoStack = redoStack
    }
    
    private var undoStack: [UndoableTextInputCommand] = []
    private var redoStack: [UndoableTextInputCommand] = []

    func push(_ command: UndoableTextInputCommand) {
        undoStack.append(command)
        redoStack.removeAll()
    }

    func undo() {
        guard let command = undoStack.popLast(), let editor else { return }
        command.undo(editor)
        redoStack.append(command)
    }

    func redo() {
        guard let command = redoStack.popLast(), let editor  else { return }
        command.redo(editor)
        undoStack.append(command)
    }
}


final class UndoSnapshotCommand: UndoableTextInputCommand {
    private let undoRange: UITextRange?
    private let redoRange: UITextRange?
    private let insertedText: String
    private let replacedText: String
    private let selectedTextRange: UITextRange?
    private let oldSelectedTextRange: UITextRange?

    init(
        undoRange: UITextRange?,
        redoRange: UITextRange?,
        insertedText: String,
        replacedText: String,
        selectedTextRange: UITextRange?,
        oldSelectedTextRange: UITextRange?
    ) {
        self.undoRange = undoRange
        self.redoRange = redoRange
        self.insertedText = insertedText
        self.replacedText = replacedText
        self.selectedTextRange = selectedTextRange
        self.oldSelectedTextRange = oldSelectedTextRange
    }

    func execute(range: NSRange, text: String) -> Bool {
        return false
    }

    func undo(_ editor: UITextView) {
        if let undoRange {
            editor.replace(undoRange, withText: replacedText)
        }
        if let range = oldSelectedTextRange {
            editor.selectedTextRange = range
        }
    }

    func redo(_ editor: UITextView) {
        if let redoRange {
            editor.replace(redoRange, withText: insertedText)
        }
        if let range = selectedTextRange {
            editor.selectedTextRange = range
        }
    }
}
