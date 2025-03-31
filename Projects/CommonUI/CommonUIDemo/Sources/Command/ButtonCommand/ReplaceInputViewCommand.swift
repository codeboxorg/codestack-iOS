
import UIKit


final class ReplaceInputViewCommand: ButtonCommand {
    weak var controller: EditorReplaceInputView?
    
    init(controller: EditorReplaceInputView? = nil) {
        self.controller = controller
    }
    
    func excute() {
        controller?.replaceInputView()
    }
}
