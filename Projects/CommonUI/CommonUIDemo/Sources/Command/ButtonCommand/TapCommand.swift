import UIKit

struct TapCommand: ButtonCommand {
    
    weak var editor: UITextView?
    
    init(editor: UITextView?) {
        self.editor = editor
    }
    
    func execute() {
        self.editor?.insertText("\t")
    }
}

