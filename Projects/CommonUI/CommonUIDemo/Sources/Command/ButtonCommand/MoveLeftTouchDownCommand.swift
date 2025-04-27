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
        controller.moveTimer?.invalidate()
        controller.moveTimer = Timer.scheduledTimer(withTimeInterval: 0.06, repeats: true) { [weak self] _ in
            MoveLeftCommand(layout: self?.layout).execute()
        }
    }
}
