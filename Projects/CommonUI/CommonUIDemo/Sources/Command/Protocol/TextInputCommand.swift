import UIKit

protocol TextInputCommand: Command {
    func shouldHandle(text: String) -> Bool
    func execute(range: NSRange, text: String) -> Bool
}

extension TextInputCommand {
    func excute() { }
    var controlType: UIControl.Event { .valueChanged }
}
