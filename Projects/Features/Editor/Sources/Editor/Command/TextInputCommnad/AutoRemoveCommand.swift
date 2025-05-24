
import Foundation
#if DEV
import Global
#endif


struct AutoRemoveCommand: TextInputCommand {
    
    weak var commandExecutor: AutoRemoveCommandExecutor?
    
    var commandState: CommandExcuteState {
        .autoPairChar
    }
    
    
    init(commandExecutor: AutoRemoveCommandExecutor?) {
        self.commandExecutor = commandExecutor
    }
    
    @inlinable
    func shouldHandle(text: String) -> Bool {
        text.isEmpty
    }
    
    func execute(range: NSRange, text: String) -> Bool {
        commandExecutor?.autoRemoveCommandExecute(range: range, text: text) ?? true
    }
}
