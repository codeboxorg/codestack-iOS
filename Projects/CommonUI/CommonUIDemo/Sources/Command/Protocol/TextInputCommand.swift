import UIKit

protocol TextInputCommand: Command {
    func shouldHandle(text: String) -> Bool
    func execute(range: NSRange, text: String) -> Bool
}

extension TextInputCommand {
    func execute() { }
    func execute(range: NSRange, text: String) -> Bool {
        return false
    }
    var controlType: UIControl.Event { .valueChanged }
}
