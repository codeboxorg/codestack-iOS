import UIKit

final class MoveRightTouchDownCommand: ButtonCommand {
    weak var editor: EditorControl?
    
    var controlType: UIControl.Event {
        .touchDown
    }
    
    init(editor: EditorControl?) {
        self.editor = editor
    }
    
    func excute() {
        editor?.moveTimer?.invalidate()
        editor?.moveTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { _ in
            MoveRightCommand(editor: self.editor?.textView).excute()
        }
    }
}
