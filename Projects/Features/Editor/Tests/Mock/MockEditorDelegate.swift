@testable import Editor
import UIKit
import Global

final class MockEditorDelegate: NSObject, UITextViewDelegate {
    
    var textInputCommandExcuteManager: DefaultTextInputCommandExcuteManager!
    var suggestionManager: CompositeSuggestionManager!
    var cursorCommand: SuggestFocusCusorCommand
    
    init(
        textInputCommandExcuteManager: DefaultTextInputCommandExcuteManager!,
        suggestionManager: CompositeSuggestionManager!,
        cusorCommand: SuggestFocusCusorCommand
    ) {
        self.textInputCommandExcuteManager = textInputCommandExcuteManager
        self.suggestionManager = suggestionManager
        self.cursorCommand = cusorCommand
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        Log.debug("textViewDidChangeSelection")
        if cursorCommand.shouldHandle {
            cursorCommand.execute()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        Log.debug("textViewDidChange")
        suggestionManager.suggestionLayoutGenerate()
        if let (oldTextRange, range, text) = SystemInsertSnapShot.shared.useWhenTextDidChange {
            textInputCommandExcuteManager
                .systemInsertActionSnapShot(
                    oldTextRange: oldTextRange,
                    shouldChangeTextIn: range,
                    replacementText: text
                )
            SystemInsertSnapShot.shared.useWhenTextDidChange = nil
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        Log.debug("shouldChangeTextIn")
        return textInputCommandExcuteManager.commandExecute(shouldChangeTextIn: range, replacementText: text)
    }
}
