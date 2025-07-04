import Foundation

struct ReplaceInputViewCommand: ButtonCommand {
    weak var controller: EditorReplaceInputView?
    
    init(controller: EditorReplaceInputView? = nil) {
        self.controller = controller
    }
    
    func execute() {
        controller?.replaceInputView()
    }
}
