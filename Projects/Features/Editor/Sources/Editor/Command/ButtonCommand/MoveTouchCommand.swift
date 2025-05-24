import UIKit


final class MoveTouchUpCommand: ButtonCommand {
    var controlType: UIControl.Event {
        .touchUpInside
    }
    
    private weak var layout: ButtonCommandExecuteManager?
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        layout?.moveTouchUpCommand()
    }
}


final class MoveTouchOutCommand: ButtonCommand {
    var controlType: UIControl.Event {
        .touchUpOutside
    }
    
    private weak var layout: ButtonCommandExecuteManager?
    
    init(layout: ButtonCommandExecuteManager?) {
        self.layout = layout
    }
    
    func execute() {
        layout?.moveTouchOutCommand()
    }
}
