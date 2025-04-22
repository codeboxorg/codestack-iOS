
import UIKit
#if DEV
import Global
#endif



struct AutoRemoveCommand: TextInputCommand {
    
    weak var editor: UITextView?
    
    var commandState: CommandExcuteState {
        .autoPairChar
    }
    
    
    init(_ editor: UITextView?) {
        self.editor = editor
    }
    
    @inlinable
    func shouldHandle(text: String) -> Bool {
        text.isEmpty
    }
    
    func execute(range: NSRange, text: String) -> Bool {
        guard let editor else {
            return true
        }
        
        let removalIndex = editor.text.index(editor.text.startIndex, offsetBy: range.location, limitedBy: editor.text.endIndex)
        let prevCharIndex = editor.text.index(editor.text.startIndex, offsetBy: range.location + 1, limitedBy: editor.text.endIndex)
        let end = editor.text.endIndex
        
        if let removalIndex,
           let prevCharIndex,
           removalIndex < end,
           prevCharIndex < end
        {
            let willRemoveChar = editor.text[removalIndex]
            let prevChar = editor.text[prevCharIndex]
            
            if MatchingCharacter.removalPair(prev: willRemoveChar, next: prevChar),
               let start = editor.position(from: editor.beginningOfDocument, offset: range.location),
               let end   = editor.position(from: start, offset: 2),
               let replaceRange = editor.textRange(from: start, to: end)
            {
                editor.replace(replaceRange, withText: "")
                editor.selectedTextRange = editor.textRange(from: start, to: start)
                return false
            }
        }
        return true
    }
}
