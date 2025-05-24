import Foundation

protocol SuggestionManager: AnyObject {
    func initSuggestion(string: [String])
    func remove(for text: String)
    var currentFocusingItem: String { get set }
}

extension SuggestionManager {
    func initSuggestion(string: [String] = []) {
        self.initSuggestion(string: string)
    }
}

protocol SuggestionViewRemoval: AnyObject {
    func removeSuggestionView()
}

protocol SuggestionLayoutGenerator: AnyObject {
    func suggestionLayoutGenerate()
}

protocol SuggestionCusorPosition: AnyObject {
    func excuteWhenCusorPositionChanged()
    var isSuggestionFocusingState: Bool { get }
}

protocol SuggestionInsert: AnyObject {
    func insertCurrentFocusingSuggestionWord()
}

protocol SuggestionGenerator: AnyObject {
    func input(for text: String)
    func findPriorWord() -> String?
}


typealias CompositeSuggestionManager = (
    SuggestionManager &
    SuggestionViewRemoval &
    SuggestionLayoutGenerator &
    SuggestionCusorPosition &
    SuggestionInsert &
    SuggestionGenerator
)
