import UIKit

final class MoveRightTouchDownCommand: ButtonCommand {
    weak var timerControl: EditorControl?
    weak var layout: ButtonCommandExecuteManager?
    
    var controlType: UIControl.Event {
        .touchDown
    }
    
    init(timerControl: EditorControl?, layout: ButtonCommandExecuteManager?) {
        self.timerControl = timerControl
        self.layout = layout
    }
    
    func execute() {
        timerControl?.moveTimer?.invalidate()
        timerControl?.moveTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            MoveRightCommand(layout: self?.layout).execute()
        }
    }
}
