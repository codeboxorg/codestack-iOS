import UIKit

protocol Command {
    var controlType: UIControl.Event { get }
    func excute()
}

extension Command {
    func asAction() -> UIAction {
        return UIAction { _ in self.excute() }
    }
}
