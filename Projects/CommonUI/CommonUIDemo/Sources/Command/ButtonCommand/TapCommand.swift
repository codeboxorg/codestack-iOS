import UIKit

struct TapCommand: ButtonCommand {
    
    weak var editor: UITextView?
    
    init(editor: UITextView?) {
        self.editor = editor
    }
    
    func excute() {
        self.editor?.insertText("\t")
    }
}

