import UIKit

struct TapCommand: ButtonCommand {
    
    weak var layout: ButtonCommandExecuteManager?
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        
    }
}

