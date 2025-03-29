import UIKit


final class MoveTouchUpCommand: ButtonCommand {
    var controlType: UIControl.Event {
        .touchUpInside
    }
    
    private weak var editor: EditorControl?
    
    init(editor: EditorControl?) {
        self.editor = editor
    }
    
    func excute() {
        self.editor?.moveTimer?.invalidate()
        self.editor?.moveTimer = nil
    }
}


final class MoveTouchOutCommand: ButtonCommand {
    var controlType: UIControl.Event {
        .touchUpOutside
    }
    
    private weak var editor: EditorControl?
    
    init(editor: EditorControl?) {
        self.editor = editor
    }
    
    func excute() {
        self.editor?.moveTimer?.invalidate()
        self.editor?.moveTimer = nil
    }
}
