import UIKit

final class MoveLeftTouchDownCommand: ButtonCommand {
    
    var controlType: UIControl.Event {
        .touchDown
    }
    
    private weak var editor: EditorControl?
    
    init(editor: EditorControl?) {
        self.editor = editor
    }
    
    func excute() {
        editor?.moveTimer?.invalidate()
        editor?.moveTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { _ in
            MoveLeftCommand(editor: self.editor?.textView).excute()
        }
    }
}
