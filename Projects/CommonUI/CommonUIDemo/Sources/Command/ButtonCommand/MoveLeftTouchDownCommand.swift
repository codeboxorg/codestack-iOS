import UIKit

final class MoveLeftTouchDownCommand: ButtonCommand {
    
    var controlType: UIControl.Event {
        .touchDown
    }
    
    private weak var timerControl: EditorControl?
    private weak var layout: ButtonCommandExecuteManager?
    
    init(timerControl: EditorControl?, layout: ButtonCommandExecuteManager?) {
        self.timerControl = timerControl
        self.layout = layout
    }
    
    func execute() {
        timerControl?.moveTimer?.invalidate()
        timerControl?.moveTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            MoveLeftCommand(layout: self?.layout).execute()
        }
    }
}
