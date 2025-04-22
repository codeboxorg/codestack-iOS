import Foundation
import Global

struct SuggestionEnterCommand: TextInputCommand {
    
    weak var suggestionManager: SuggestionManager?
    var commandState: CommandExcuteState {
        .suggestionEnter
    }
    init(
        suggestionManager: SuggestionManager?
    ) {
        self.suggestionManager = suggestionManager
    }
    
    @inlinable
    func shouldHandle(text: String) -> Bool {
        let isEnter = text == "\n" ? true : false
        if !isEnter {
            return false
        }
        guard let shouldHandle = suggestionManager?.isSuggestionFocusingState else {
            return false
        }
        return shouldHandle
    }
    
    func execute(range: NSRange, text: String) -> Bool {
        guard let suggestionManager else {
            return true
        }
        
        suggestionManager.insertCurrentFocusingSuggestionWord()
        
        return false
    }
}
