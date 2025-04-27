import UIKit

protocol ButtonCommandExecuteManager: AnyObject {
    var allCommandButtons: [UIButton] { get }
    var symbolAlert: UIButton { get }
    var replaceInputViewDelegate: EditorReplaceInputView? { get set }
    
    func doneExecute()
    func tapButtonExecute()
    
    func moveLeftButtonExecute()
    func moveRightCommand()
    
    func moveTouchUpCommand()
    func moveTouchOutCommand()
    
    func undoButtonExecute()
    func redoButtonExecute()
    
    func deleteLine()
}

protocol UpdateUndoRedoButtonStateDelegate: AnyObject {
    func updateUndoRedoButtonState()
}


final class DefaultButtonCommandExecuteManager: ButtonCommandExecuteManager,
                                                EditorControl,
                                                UpdateUndoRedoButtonStateDelegate {
    
    var moveTimer: Timer?
    weak var editor: UITextView?
    weak var undoableManager: UndoableManager!
    weak var replaceInputViewDelegate: EditorReplaceInputView?
    
    private let undoButton: UIButton
    private let redoButton: UIButton
    lazy var symbolAlert: UIButton = {
        let button = EditorButtonGenerator.generate(type:
                .symbol(
                    ReplaceInputViewCommand(
                        controller: replaceInputViewDelegate
                    )
                )
        )
        button.accessibilityIdentifier = "symbolAlertButton"
        return button
    }()
    
    init(
        editor: UITextView? = nil,
        undoableManager: UndoableManager
    ) {
        self.editor = editor
        self.undoableManager = undoableManager
        
        defer {
            self.undoableManager.updateUndoRedoButtonStateDelegate = self
        }
        
        self.undoButton = UIButton(type: .system)
        self.redoButton = UIButton(type: .system)
        
        self.undoButton.accessibilityIdentifier = "undoButton"
        self.undoButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        self.undoButton.addAction(UIAction { [weak self] _ in
            self?.undoButtonExecute()
        }, for: .touchUpInside)

        self.redoButton.accessibilityIdentifier = "redoButton"
        self.redoButton.setImage(UIImage(systemName: "arrow.uturn.forward"), for: .normal)
        self.redoButton.addAction(UIAction { [weak self] _ in
            self?.redoButtonExecute()
        }, for: .touchUpInside)
        
        self.updateUndoRedoButtonState()
    }
    
    func doneExecute() {
        self.editor?.endEditing(true)
    }
    
    func tapButtonExecute() {
        self.editor?.insertText("\t")
    }
    
    func moveLeftButtonExecute() {
        guard let editor else { return }
        let currentPosition = editor.selectedRange.location
        let newPosition = max(0, currentPosition - 1)
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: newPosition) {
            editor.selectedTextRange = editor.textRange(from: position, to: position)
        }
    }
    
    func moveRightCommand() {
        guard let editor else { return }
        let currentPosition = editor.selectedRange.location
        let newPosition = min((editor.text as NSString).length, currentPosition + 1)
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: newPosition) {
            editor.selectedTextRange = editor.textRange(from: position, to: position)
        }
    }
    
    func moveTouchUpCommand() {
        self.moveTimer?.invalidate()
        self.moveTimer = nil
    }
    
    func moveTouchOutCommand() {
        self.moveTimer?.invalidate()
        self.moveTimer = nil
    }
    
    func undoButtonExecute() {
        self.undoableManager.undo()
        self.updateUndoRedoButtonState()
    }
    
    func redoButtonExecute() {
        self.undoableManager.redo()
        self.updateUndoRedoButtonState()
    }
    
    func updateUndoRedoButtonState() {
        undoButton.isEnabled = undoableManager.isUndoable
        redoButton.isEnabled = undoableManager.isRedoable
    }
    
    
    func deleteLine() {
        guard let editor else { return }
        
        // 1. Define paragraph range and contents
        let paragraphRange = (editor.text as NSString).paragraphRange(for: editor.selectedRange)
        let paragraphText = (editor.text as NSString).substring(with: paragraphRange)
        let oldSelectedTextRange = editor.selectedTextRange
        
        // 2. Calculate undo and redo text ranges
        guard let startPosition = editor.position(from: editor.beginningOfDocument, offset: paragraphRange.location),
              let redoEndPosition = editor.position(from: startPosition, offset: paragraphRange.length) else {
            return
        }
        
        let undoEndPosition = startPosition // Undo deletes everything → undo range is empty at start
        let undoRange = editor.textRange(from: startPosition, to: undoEndPosition)
        let redoRange = editor.textRange(from: startPosition, to: redoEndPosition)
        
        // 3. Determine new cursor position after deletion
        let newCursorOffset = max(0, paragraphRange.location - 1)
        let newCursorPosition = editor.position(from: editor.beginningOfDocument, offset: newCursorOffset)
        let newSelectedTextRange = newCursorPosition.flatMap { editor.textRange(from: $0, to: $0) }
        
        // 4. Register Undo Snapshot
        let undoCommand = UndoSnapshotCommand(
            actionCommandType: .systemRemove,
            undoRange: undoRange,
            redoRange: redoRange,
            insertedText: "",
            replacedText: paragraphText,
            selectedTextRange: newSelectedTextRange,
            oldSelectedTextRange: oldSelectedTextRange
        )
        undoableManager?.push(undoCommand)
        
        // 5. Perform deletion
        if let redoRange {
            editor.replace(redoRange, withText: "")
        }
        
        if let newSelectedTextRange {
            editor.selectedTextRange = newSelectedTextRange
        }
    }
}


// MARK: UIKIT UIButton Generator
extension DefaultButtonCommandExecuteManager {
    var allCommandButtons: [UIButton] {
        [done, tapButton, moveLeftButton, moveRightButton, symbolAlert, undoButton, redoButton, deleteLineButton]
    }
    
    var done: UIButton {
        let button = EditorButtonGenerator.generate(type: .done(DoneCommand(layout: self)))
        button.accessibilityIdentifier = "doneButton"
        return button
    }
    
    var tapButton: UIButton {
        let button = EditorButtonGenerator.generate(type: .tap(TapCommand(layout: self)))
        button.accessibilityIdentifier = "tapButton"
        return button
    }
    
    var moveLeftButton: UIButton {
        let button = EditorButtonGenerator.generate(type: .moveLeft([
            MoveLeftCommand(layout: self),
            MoveLeftTouchDownCommand(layout: self),
            MoveTouchUpCommand(layout: self),
            MoveTouchOutCommand(layout: self),
        ]))
        button.accessibilityIdentifier = "moveLeftButton"
        return button
    }
    
    var moveRightButton: UIButton {
        let button = EditorButtonGenerator.generate(type: .moveRight([
            MoveRightCommand(layout: self),
            MoveRightTouchDownCommand(layout: self),
            MoveTouchUpCommand(layout: self),
            MoveTouchOutCommand(layout: self)
        ]))
        button.accessibilityIdentifier = "moveRightButton"
        return button
    }
    
    var deleteLineButton: UIButton {
        EditorButtonGenerator.generate(
            type: .deleteLine(
                DeleteLineCommand(layout: self)
            )
        )
    }
}
