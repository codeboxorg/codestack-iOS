import UIKit
import CommonUI

protocol TextInputCommand: Command {
    var commandState: CommandExcuteState { get }
    func shouldHandle(text: String) -> Bool
    func shouldHandle(text: String, state: Set<CommandExcuteState>) -> Bool
    func execute(range: NSRange, text: String) -> Bool
    func execute(range: NSRange, text: String) -> TextInputCommandResult?
    func execute(range: NSRange, text: String, state: inout Set<CommandExcuteState>) -> TextInputCommandResult?
}

extension TextInputCommand {
    func execute() { }
    func execute(range: NSRange, text: String) -> Bool {
        return false
    }
    var controlType: UIControl.Event { .valueChanged }
    
    func shouldHandle(text: String, state: Set<CommandExcuteState>) -> Bool {
        self.shouldHandle(text: text)
    }
    
    func execute(range: NSRange, text: String, state: inout Set<CommandExcuteState>) -> TextInputCommandResult? {
        guard let result = execute(range: range, text: text) else {
            return nil
        }
        
        state.insert(self.commandState)
        
        return TextInputCommandResult(
            replacementRange: result.replacementRange,
            replacementText: result.replacementText,
            newSelectedRange: result.newSelectedRange,
            state: state
        )
    }
}
