import UIKit

struct MoveRightCommand: ButtonCommand {
    
    weak var editor: UITextView?
    
    init(editor: UITextView?) {
        self.editor = editor
    }
    
    func excute() {
        guard let editor = editor else { return }
        let currentPosition = editor.selectedRange.location
        let newPosition = min((editor.text as NSString).length, currentPosition + 1)
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: newPosition) {
            editor.selectedTextRange = editor.textRange(from: position, to: position)
        }
    }
}

