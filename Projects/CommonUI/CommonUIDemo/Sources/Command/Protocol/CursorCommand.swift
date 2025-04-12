import UIKit

protocol CursorCommand: Command {
    var shouldHandle: Bool { get }
}

extension CursorCommand {
    func execute() { }
    var controlType: UIControl.Event { .valueChanged }
}
