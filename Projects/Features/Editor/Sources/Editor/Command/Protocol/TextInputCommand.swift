import UIKit
import CommonUI

protocol TextInputCommand: Command {
    var commandState: CommandExcuteState { get }
    func shouldHandle(text: String) -> Bool
    func shouldHandle(text: String, state: Set<CommandExcuteState>) -> Bool
    func execute(range: NSRange, text: String) -> Bool
    func execute(range: NSRange, text: String, state: inout Set<CommandExcuteState>) -> Bool
}

extension TextInputCommand {
    func execute() { }
    var controlType: UIControl.Event { .valueChanged }
    
    func shouldHandle(text: String, state: Set<CommandExcuteState>) -> Bool {
        self.shouldHandle(text: text)
    }
    
    func execute(range: NSRange, text: String, state: inout Set<CommandExcuteState>) -> Bool {
        state.insert(commandState)
        return self.execute(range: range, text: text)
    }
}
