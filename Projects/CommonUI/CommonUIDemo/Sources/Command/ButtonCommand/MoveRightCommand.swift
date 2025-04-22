import UIKit

struct MoveRightCommand: ButtonCommand {
    
    weak var layout: ButtonCommandExecuteManager?
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        layout?.moveRightCommand()
    }
}

