import Foundation
import Global

struct SuggestionGeneratorCommand: TextInputCommand {
    
    weak var suggestionManager: SuggestionGenerator?
    var commandState: CommandExcuteState {
        .suggestionGenerator
    }
    
    init(
        suggestionManager: SuggestionGenerator?
    ) {
        self.suggestionManager = suggestionManager
    }
    
    func shouldHandle(text: String) -> Bool {
        guard
            text.count == 1,
            let scalar = text.unicodeScalars.first
        else {
            return false
        }
        return CharacterSet.alphanumerics.inverted.contains(scalar)
    }
    
    func execute(range: NSRange, text: String) -> Bool {
        guard
            let suggestionManager,
            let word = suggestionManager.findPriorWord()
        else {
            return true
        }
        suggestionManager.input(for: word)
        
        return true
    }
}
