import UIKit

struct DeleteLineCommand: ButtonCommand {
    
    weak var layout: ButtonCommandExecuteManager?
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        layout?.deleteLine()
    }
}

