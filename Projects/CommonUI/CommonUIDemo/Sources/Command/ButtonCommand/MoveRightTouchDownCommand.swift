import UIKit

final class MoveRightTouchDownCommand: ButtonCommand {
    weak var layout: ButtonCommandExecuteManager?
    
    var controlType: UIControl.Event {
        .touchDown
    }
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        guard let timerControl = layout as? EditorControl else {
            return
        }
        timerControl.moveTimer?.invalidate()
        timerControl.moveTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            MoveRightCommand(layout: self?.layout).execute()
        }
    }
}
