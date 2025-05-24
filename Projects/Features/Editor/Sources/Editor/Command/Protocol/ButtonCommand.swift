import UIKit

protocol ButtonCommand: Command {
    var controlType: UIControl.Event { get }
}

extension ButtonCommand {
    var controlType: UIControl.Event {
        .touchUpInside
    }
}
