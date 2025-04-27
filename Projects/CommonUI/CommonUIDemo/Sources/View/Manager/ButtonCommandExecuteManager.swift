import UIKit

protocol ButtonCommandExecuteManager: AnyObject {
    var allCommandButtons: [UIButton] { get }
    var replaceInputViewDelegate: EditorReplaceInputView? { get set }
    
    func doneExecute()
    func tapButtonExecute()
    
    func moveLeftButtonExecute()
    func moveRightCommand()
    
    func moveTouchUpCommand()
    func moveTouchOutCommand()
    
    func undoButtonExecute()
    func redoButtonExecute()
protocol UpdateUndoRedoButtonStateDelegate: AnyObject {
    func updateUndoRedoButtonState()
}


final class DefaultButtonCommandExecuteManager: ButtonCommandExecuteManager {
                                                EditorControl,
                                                UpdateUndoRedoButtonStateDelegate {
    
    var moveTimer: Timer?
    weak var editor: UITextView?
    weak var undoableManager: UndoableManager!
    weak var replaceInputViewDelegate: EditorReplaceInputView?
    
    init(
        editor: UITextView? = nil,
        undoableManager: UndoableManager
    ) {
        self.editor = editor
        self.undoableManager = undoableManager
        defer {
            self.undoableManager.updateUndoRedoButtonStateDelegate = self
        }
        
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


// MARK: UIKIT UIButton Generator
extension DefaultButtonCommandExecuteManager {
    var allCommandButtons: [UIButton] {
        [done, tapButton, moveLeftButton, moveRightButton, symbolAlert, undoButton, redoButton]
    }
    
    var done: UIButton {
        EditorButtonGenerator.generate(type: .done(DoneCommand(layout: self)))
    }
    
    var tapButton: UIButton {
        EditorButtonGenerator.generate(type: .tap(TapCommand(layout: self)))
    }
    
    var moveLeftButton: UIButton {
        EditorButtonGenerator.generate(type: .moveLeft([
            MoveLeftCommand(layout: self),
            MoveLeftTouchDownCommand(timerControl: editorControl, layout: self),
            MoveTouchUpCommand(layout: self),
            MoveTouchOutCommand(layout: self),
        ]))
    }
    
    var moveRightButton: UIButton {
        EditorButtonGenerator.generate(type: .moveRight([
            MoveRightCommand(layout: self),
            MoveRightTouchDownCommand(timerControl: editorControl, layout: self),
            MoveTouchUpCommand(layout: self),
            MoveTouchOutCommand(layout: self)
        ]))
    }
    
    var symbolAlert: UIButton {
        EditorButtonGenerator.generate(type: .symbol(ReplaceInputViewCommand(controller: (editorControl as? EditorReplaceInputView))))
    }

    var undoButton: UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Undo", for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.undoButtonExecute()
        }, for: .touchUpInside)
        return button
    }

    var redoButton: UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Redo", for: .normal)
        button.addAction(UIAction { [weak self] _ in
            self?.redoButtonExecute()
        }, for: .touchUpInside)
        return button
    }
}
