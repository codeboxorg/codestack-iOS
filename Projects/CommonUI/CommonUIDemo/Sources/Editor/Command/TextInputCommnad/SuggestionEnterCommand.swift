import Foundation
import Global

struct SuggestionEnterCommand: TextInputCommand {
    
    weak var suggestionManager: SuggestionInsert?
    var commandState: CommandExcuteState {
        .suggestionEnter
    }
    init(
        suggestionManager: SuggestionInsert?
    ) {
        self.suggestionManager = suggestionManager
    }
    
    @inlinable
    func shouldHandle(text: String) -> Bool {
        let isEnter = text == "\n" ? true : false
        if !isEnter {
            return false
        }
        guard let shouldHandle = (suggestionManager as? SuggestionCusorPosition)?.isSuggestionFocusingState else {
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
