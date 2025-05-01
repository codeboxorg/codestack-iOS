import Foundation
import Global

struct EnterCommand: TextInputCommand {
    
    weak var suggestionLayout: SuggestionLayout?
    weak var commandExecutor: EnterCommandExecutor?
    
    var commandState: CommandExcuteState {
        .enter
    }
    
    init(
        suggestionLayout: SuggestionLayout?,
        commandExecutor: EnterCommandExecutor?
    ) {
        self.suggestionLayout = suggestionLayout
        self.commandExecutor = commandExecutor
    }
    
    func shouldHandle(text: String, state: Set<CommandExcuteState>) -> Bool {
        if state.contains(.suggestionEnter) { return false }
        return shouldHandle(text: text)
    }
    
    @inlinable
    func shouldHandle(text: String) -> Bool {
        let isEnter = text == "\n" ? true : false
        
        if !isEnter {
            return false
        }
        
        if let state = suggestionLayout?.state,
           case .focusing = state {
            return false
        } else {
            return true
        }
    }

    func execute(range: NSRange, text: String) -> Bool {
        guard let commandExecutor else {
            return true
        }
        return commandExecutor.enterCommandExecute(range: range, text: text)
    }
}
