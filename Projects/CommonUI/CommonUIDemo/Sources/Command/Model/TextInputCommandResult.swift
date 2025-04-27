import UIKit

struct TextInputCommandResult: Equatable {
    var actionCommandType: ActionCommandType
    var replacementRange: UITextRange
    var replacementText: String
    var newSelectedRange: UITextRange?
    var offset: Int?
    
    init(
        actionCommandType: ActionCommandType,
        replacementRange: UITextRange,
        replacementText: String,
        newSelectedRange: UITextRange?,
        offset: Int? = nil
    ) {
        self.actionCommandType = actionCommandType
        self.replacementRange = replacementRange
        self.replacementText = replacementText
        self.newSelectedRange = newSelectedRange
        self.offset = offset
    }
}

