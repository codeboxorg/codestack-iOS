import UIKit

struct DoneCommand: ButtonCommand {
    
    weak var editor: UITextView?
    
    init(editor: UITextView?) {
        self.editor = editor
    }
    
    func excute() {
        self.editor?.endEditing(true)
    }
}

