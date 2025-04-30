import UIKit

final class MoveLeftTouchDownCommand: ButtonCommand {
    
    var controlType: UIControl.Event {
        .touchDown
    }
    
    private weak var layout: ButtonCommandExecuteManager?
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        guard let controller = layout as? EditorControl else {
            return
        }
        controller.moveLeftTimerTouchExecute()
    }
}
