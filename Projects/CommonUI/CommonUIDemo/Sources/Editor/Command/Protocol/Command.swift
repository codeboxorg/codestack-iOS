import UIKit

protocol Command {
    var controlType: UIControl.Event { get }
    func execute()
}

extension Command {
    func asAction() -> UIAction {
        return UIAction { _ in self.execute() }
    }
}
