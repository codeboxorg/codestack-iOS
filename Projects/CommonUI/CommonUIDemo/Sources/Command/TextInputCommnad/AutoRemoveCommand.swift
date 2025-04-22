
import Foundation
#if DEV
import Global
#endif


struct AutoRemoveCommand: TextInputCommand {
    
    weak var commandExecutor: TextInputCommandExcuteManager?
    
    var commandState: CommandExcuteState {
        .autoPairChar
    }
    
    
    init(commandExecutor: TextInputCommandExcuteManager?) {
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
