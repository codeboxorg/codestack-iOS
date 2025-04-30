import UIKit
import Global


enum ActionCommandType: String {
    case suggestionEnter
    case systemInput
    case systemReplace
    case systemRemove
    case enterCommand
    case autoPairInsert
    case autoPairRemove
    case deleteLine
}

protocol UndoableManager: AnyObject {
    var updateUndoRedoButtonStateDelegate: UpdateUndoRedoButtonStateDelegate? { get set }
    var isUndoable: Bool { get }
    var isRedoable: Bool { get }
    func push(_ command: UndoableTextInputCommand)
    func undo()
    func redo()
}

final class DefaultUndoableManager: UndoableManager {
    private weak var editor: UITextView?
    private(set) var undoManager = UndoManager()
    weak var updateUndoRedoButtonStateDelegate: UpdateUndoRedoButtonStateDelegate?
    
    
    var isUndoable: Bool {
        undoManager.canUndo
    }
    var isRedoable: Bool {
        undoManager.canRedo
    }

    init(editor: UITextView? = nil) {
        self.editor = editor
        editor?.undoManager?.disableUndoRegistration()
    }

    func push(_ command: UndoableTextInputCommand) {
        undoManager.registerUndo(withTarget: self) { target in
            guard let editor = target.editor else { return }
            
            command.undo(editor)
            
            target.undoManager.registerUndo(withTarget: target) { innerTarget in
                guard let editor = innerTarget.editor else { return }
                command.redo(editor)
                innerTarget.push(command)
            }
        }
        undoManager.setActionName("\(command.actionCommandType.rawValue)")
        updateUndoRedoButtonStateDelegate?.updateUndoRedoButtonState()
    }

    func undo() {
        undoManager.undo()
    }

    func redo() {
        undoManager.redo()
    }
}


final class UndoSnapshotCommand: UndoableTextInputCommand {
    let actionCommandType: ActionCommandType
    private let undoRange: UITextRange?
    private let redoRange: UITextRange?
    private let insertedText: String
    private let replacedText: String
    private let selectedTextRange: UITextRange?
    private let oldSelectedTextRange: UITextRange?
    
    var getNewSelectedRange: UITextRange? { selectedTextRange }
    var getRedoRange: UITextRange? { redoRange }

    init(
        actionCommandType: ActionCommandType,
        undoRange: UITextRange?,
        redoRange: UITextRange?,
        insertedText: String,
        replacedText: String,
        selectedTextRange: UITextRange?,
        oldSelectedTextRange: UITextRange?
    ) {
        self.actionCommandType = actionCommandType
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
