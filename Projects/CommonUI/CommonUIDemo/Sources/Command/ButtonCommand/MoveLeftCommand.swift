import UIKit

struct MoveLeftCommand: ButtonCommand {
    
    weak var editor: UITextView?
    
    init(editor: UITextView?) {
        self.editor = editor
    }
    
    func excute() {
        guard let editor = editor else { return }
        let currentPosition = editor.selectedRange.location
        let newPosition = max(0, currentPosition - 1)
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: newPosition) {
            editor.selectedTextRange = editor.textRange(from: position, to: position)
        }
    }
}
