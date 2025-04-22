import Foundation


struct AutoPairCharacterCommand: TextInputCommand {
    
    weak var commandExecutor: TextInputCommandExcuteManager?
    
    var commandState: CommandExcuteState {
        .autoPairChar
    }
    
    init(commandExecutor: TextInputCommandExcuteManager?) {
        self.commandExecutor = commandExecutor
    }
    
    func shouldHandle(text: String) -> Bool {
        MatchingCharacter.matchingCharacter(text) != nil && text.first == text.last
    }

    func execute(range: NSRange, text: String) -> Bool {
        commandExecutor?.autoPairExecute(range: range, text: text) ?? false
    }
}
