import UIKit
#if DEV
import Global
#endif


protocol TextInputCommandExcuteManager {
    func commandExecute(shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func systemInsertActionSnapShot(oldTextRange: UITextRange, shouldChangeTextIn range: NSRange, replacementText text: String)
}

final class DefaultTextInputCommandExcuteManager: TextInputCommandExcuteManager {
    weak var editor: Editor?
    weak var undoableManager: UndoableManager?
    private var resolver: TextRangeResolver
    private var inputCommands: [TextInputCommand]
    
    init(
        editor: Editor?,
        undoableManager: UndoableManager?,
        textRangeResolver: TextRangeResolver,
        textInputCommands: TextInputCommand...
    )
    {
        self.editor = editor
        self.resolver = textRangeResolver
        self.undoableManager = undoableManager
        self.inputCommands = textInputCommands
    }
    
    func systemInsertActionSnapShot(oldTextRange: UITextRange, shouldChangeTextIn range: NSRange, replacementText text: String) {
        let undoCommand = resolver.insertSnapshot(oldTextRange, range, text)
        
        undoableManager?.push(undoCommand)
    }
    
    func commandExecute(shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var systemUpdate = true
        var state = Set<CommandExcuteState>()
        
        for command in inputCommands {
            if command.shouldHandle(text: text, state: state) {
                let commandUpdate = command.execute(
                    range: range,
                    text: text,
                    state: &state
                )
                if commandUpdate == false {
                    systemUpdate = false
                }
            }
        }
        
        if systemUpdate {
            if range.length >= 1 && text.count == 0 {
                let undoCommand = resolver.removeSnapShot(range, text)
                undoableManager?.push(undoCommand)
            } else if range.length >= 1 && text.count != 0 {
                let undoCommand = resolver.replaceSnapshot(range, text)
                undoableManager?.push(undoCommand)
            } else {
                SystemInsertSnapShot.shared.useWhenTextDidChange = (editor!.selectedTextRange!, range, text)
            }
            return true
        } else {
            return false
        }
    }
}
