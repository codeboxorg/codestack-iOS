import UIKit

struct MoveLeftCommand: ButtonCommand {
    
    weak var layout: ButtonCommandExecuteManager?
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        layout?.moveLeftButtonExecute()
    }
}
