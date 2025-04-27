import UIKit

struct TextInputCommandResult: Equatable {
    var actionCommandType: ActionCommandType
    var replacementRange: UITextRange
    var replacementText: String
    var newSelectedRange: UITextRange?
    
    init(
        actionCommandType: ActionCommandType,
        replacementRange: UITextRange,
        replacementText: String,
        newSelectedRange: UITextRange?
    ) {
        self.actionCommandType = actionCommandType
        self.replacementRange = replacementRange
        self.replacementText = replacementText
        self.newSelectedRange = newSelectedRange
    }
}

