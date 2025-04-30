import Foundation
import Global

struct SuggestionGeneratorCommand: TextInputCommand {
    
    weak var suggestionManager: SuggestionManager?
    var commandState: CommandExcuteState {
        .suggestionGenerator
    }
    
    init(
        suggestionManager: SuggestionManager?
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
        Log.debug("word: \(word)")
        suggestionManager.input(for: word)
        
        return true
    }
}
