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
    private lazy var resolver: TextRangeResolver = TextRangeResolver(editor: self.editor!)
    
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
        button.accessibilityIdentifier = AccessoryButtonIdentifier.symbolAlertButton.string
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
        
        self.undoButton.accessibilityIdentifier = AccessoryButtonIdentifier.undoButton.string
        self.undoButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        self.undoButton.addAction(UIAction { [weak self] _ in
            self?.undoButtonExecute()
        }, for: .touchUpInside)

        self.redoButton.accessibilityIdentifier = AccessoryButtonIdentifier.redoButton.string
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
        guard let selectedTextRange = editor?.selectedTextRange else {
            return
        }
        SystemInsertSnapShot.shared.useWhenTextDidChange = (selectedTextRange, editor!.selectedRange, "\t")
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
    
    func moveLeftTimerTouchExecute() {
        moveTimer?.invalidate()
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            MoveLeftCommand(layout: self).execute()
        }
    }
    
    func moveRightTimerTouchExecute() {
        moveTimer?.invalidate()
        moveTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            MoveRightCommand(layout: self).execute()
        }
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
        
        guard let snapshotCommand = resolver.deleteLineSnapShot() else {
            return
        }
        
        undoableManager?.push(snapshotCommand)
        
        // 5. Perform deletion
        if let redoRange = snapshotCommand.getRedoRange {
            editor.replace(redoRange, withText: "")
        }
        
        if let newSelectedTextRange = snapshotCommand.getNewSelectedRange {
            editor.selectedTextRange = newSelectedTextRange
        }
    }
}


// MARK: UIKIT UIButton Generator
extension DefaultButtonCommandExecuteManager {
    
    enum AccessoryButtonIdentifier: String {
        case doneButton
        case tapButton
        case moveLeftButton
        case moveRightButton
        case symbolAlertButton
        case undoButton
        case redoButton
        case deleteLineButton
        
        var string: String {
            self.rawValue
        }
    }
    
    var allCommandButtons: [UIButton] {
        [done, tapButton, moveLeftButton, moveRightButton, symbolAlert, undoButton, redoButton, deleteLineButton]
    }
    
    var done: UIButton {
        let button = EditorButtonGenerator.generate(type: .done(DoneCommand(layout: self)))
        button.accessibilityIdentifier = AccessoryButtonIdentifier.doneButton.string
        return button
    }
    
    var tapButton: UIButton {
        let button = EditorButtonGenerator.generate(type: .tap(TapCommand(layout: self)))
        button.accessibilityIdentifier = AccessoryButtonIdentifier.tapButton.string
        return button
    }
    
    var moveLeftButton: UIButton {
        let button = EditorButtonGenerator.generate(type: .moveLeft([
            MoveLeftCommand(layout: self),
            MoveLeftTouchDownCommand(layout: self),
            MoveTouchUpCommand(layout: self),
            MoveTouchOutCommand(layout: self),
        ]))
        button.accessibilityIdentifier = AccessoryButtonIdentifier.moveLeftButton.string
        return button
    }
    
    var moveRightButton: UIButton {
        let button = EditorButtonGenerator.generate(type: .moveRight([
            MoveRightCommand(layout: self),
            MoveRightTouchDownCommand(layout: self),
            MoveTouchUpCommand(layout: self),
            MoveTouchOutCommand(layout: self)
        ]))
        button.accessibilityIdentifier = AccessoryButtonIdentifier.moveRightButton.string
        return button
    }
    
    var deleteLineButton: UIButton {
        let button = EditorButtonGenerator.generate(
            type: .deleteLine(
                DeleteLineCommand(layout: self)
            )
        )
        button.accessibilityIdentifier = AccessoryButtonIdentifier.deleteLineButton.string
        return button
    }
}
