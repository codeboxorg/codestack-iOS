import UIKit

struct TextInputCommandResult: Equatable {
    let replacementRange: UITextRange
    let replacementText: String
    let newSelectedRange: UITextRange?
    let state: Set<CommandExcuteState>
    init(
        replacementRange: UITextRange,
        replacementText: String,
        newSelectedRange: UITextRange?,
        state: Set<CommandExcuteState> = .init()
    ) {
        self.replacementRange = replacementRange
        self.replacementText = replacementText
        self.newSelectedRange = newSelectedRange
        self.state = state
    }
}

