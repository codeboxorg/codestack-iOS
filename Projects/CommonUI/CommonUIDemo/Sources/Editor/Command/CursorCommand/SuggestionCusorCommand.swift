import CommonUI
import UIKit

struct SuggestFocusCusorCommand: CursorCommand {
    weak var suggestionManager: SuggestionCusorPosition?
    
    init(suggestionManager: SuggestionCusorPosition?) {
        self.suggestionManager = suggestionManager
    }
    
    var shouldHandle: Bool {
        suggestionManager?.isSuggestionFocusingState ?? false
    }

    func execute() {
        suggestionManager?.excuteWhenCusorPositionChanged()
    }
}

