import UIKit

struct DoneCommand: ButtonCommand {
    
    weak var layout: ButtonCommandExecuteManager?
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        layout?.tapButtonExecute()
    }
}

