import UIKit

struct TextInputCommandResult: Equatable {
    var replacementRange: UITextRange
    var replacementText: String
    var newSelectedRange: UITextRange?
    
    init(
        replacementRange: UITextRange,
        replacementText: String,
        newSelectedRange: UITextRange?
    ) {
        self.replacementRange = replacementRange
        self.replacementText = replacementText
        self.newSelectedRange = newSelectedRange
    }
}

