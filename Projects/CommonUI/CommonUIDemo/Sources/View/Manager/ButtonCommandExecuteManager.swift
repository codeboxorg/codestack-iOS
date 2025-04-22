
import UIKit

protocol ButtonCommandExecuteManager: AnyObject {
    var allCommandButtons: [UIButton] { get }
    
    func doneExecute()
    func tapButtonExecute()
    
    func moveLeftButtonExecute()
    func moveRightCommand()
    
    func moveTouchUpCommand()
    func moveTouchOutCommand()
    
    func undoButtonExecute()
    func redoButtonExecute()
}


final class DefaultButtonCommandExecuteManager: ButtonCommandExecuteManager {
    
    weak var editor: UITextView?
    weak var editorControl: EditorControl?
    weak var undoableManager: UndoableManager!
    
    init(
        editor: UITextView? = nil,
        editorControl: EditorControl? = nil,
        undoableManager: UndoableManager
    ) {
        self.editor = editor
        self.editorControl = editorControl
        self.undoableManager = undoableManager
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
        self.editorControl?.moveTimer?.invalidate()
        self.editorControl?.moveTimer = nil
    }
    
    func moveTouchOutCommand() {
        self.editorControl?.moveTimer?.invalidate()
        self.editorControl?.moveTimer = nil
    }
    
    func undoButtonExecute() {
        self.undoableManager.undo()
    }
    
    func redoButtonExecute() {
        self.undoableManager.redo()
    }
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
