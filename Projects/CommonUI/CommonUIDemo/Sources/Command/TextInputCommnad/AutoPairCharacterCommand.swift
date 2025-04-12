import UIKit

struct AutoPairCharacterCommand: TextInputCommand {
    
    weak var editor: UITextView?
    
    init(_ editor: UITextView?) {
        self.editor = editor
    }
    
    func shouldHandle(text: String) -> Bool {
        MatchingCharacter.matchingCharacter(text) != nil && text.first == text.last
    }

    func execute(range: NSRange, text: String) -> Bool {
        guard let editor = editor else {
            return true
        }
        
        guard let value = MatchingCharacter.matchingCharacter(text), value.isOpening else {
            return true
        }
        
        let insertion = "\(value.rawValue)\(value.pair)"

        if let start = editor.position(from: editor.beginningOfDocument, offset: range.location),
           let end = editor.position(from: start, offset: range.length),
           let replaceRange = editor.textRange(from: start, to: end) {
            editor.replace(replaceRange, withText: insertion)
        }

        let cursorPosition = range.location + 1
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: cursorPosition) {
            editor.selectedTextRange = editor.textRange(from: position, to: position)
        }
        
        return false
    }
}
