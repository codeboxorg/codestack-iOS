import CommonUI
import UIKit

struct SuggestFocusCusorCommand: CursorCommand {
    weak var suggestionManager: SuggestionManager?
    
    init(suggestionManager: SuggestionManager?) {
        self.suggestionManager = suggestionManager
    }
    
    var shouldHandle: Bool {
        suggestionManager?.isSuggestionFocusingState ?? false
    }

    func execute() {
        suggestionManager?.excuteWhenCusorPositionChanged()
    }
}

