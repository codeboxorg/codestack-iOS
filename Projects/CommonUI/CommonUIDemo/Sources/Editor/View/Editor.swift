import CommonUI
import UIKit


public final class Editor: CodeUITextView,
                           EnterCommandExecutor,
                           AutoRemoveCommandExecutor,
                           AutoPairCommandExecutor {
    
    private lazy var resolver = TextRangeResolver(editor: self)
    weak var undoableManager: UndoableManager?
}

extension Editor {
    private func applyUndoableSnapShot(input result: TextInputCommandResult) {
        self.replace(result.replacementRange, withText: result.replacementText)
        
        let snapShot = resolver.applyUndoableSnapShot(result)
        
        self.selectedTextRange = snapShot.getNewSelectedRange
        
        undoableManager?.push(snapShot)
    }

    // MARK: Auto Pair Command
    func autoPairExecute(range: NSRange, text: String) -> Bool {
        guard let value = MatchingCharacter.matchingCharacter(text), value.isOpening else {
            return true
        }
        
        let insertion = "\(value.rawValue)\(value.pair)"
        
        var replacementRange: UITextRange?
        var replacementText : String = ""
        var newSelectedRange: UITextRange?
        
        if let start = self.position(from: self.beginningOfDocument, offset: range.location),
           let end = self.position(from: start, offset: range.length),
           let replaceRange = self.textRange(from: start, to: end) {
            replacementRange = replaceRange
            replacementText = insertion
        }

        let cursorPosition = range.location + 1
        
        if let position = self.position(from: self.beginningOfDocument, offset: cursorPosition) {
            newSelectedRange = self.textRange(from: position, to: position)
        }
        
        let result = TextInputCommandResult(
            actionCommandType: .autoPairInsert,
            replacementRange: replacementRange ?? .init(),
            replacementText: replacementText,
            newSelectedRange: newSelectedRange,
            currentSelectedRange: self.selectedTextRange,
            offset: newSelectedRange == nil ? cursorPosition : nil
        )
        
        applyUndoableSnapShot(input: result)
        
        return false
    }

    func autoRemoveCommandExecute(range: NSRange, text: String) -> Bool {
        let removalIndex = self.text.index(self.text.startIndex, offsetBy: range.location, limitedBy: self.text.endIndex)
        let prevCharIndex = self.text.index(self.text.startIndex, offsetBy: range.location + 1, limitedBy: self.text.endIndex)
        let end = self.text.endIndex
        
        if let removalIndex,
           let prevCharIndex,
           removalIndex < end,
           prevCharIndex < end
        {
            let willRemoveChar = self.text[removalIndex]
            let prevChar = self.text[prevCharIndex]
            
            if MatchingCharacter.removalPair(prev: willRemoveChar, next: prevChar),
               let start = self.position(from: self.beginningOfDocument, offset: range.location),
               let end   = self.position(from: start, offset: 2),
               let replaceRange = self.textRange(from: start, to: end)
            {
                let result = TextInputCommandResult(
                    actionCommandType: .autoPairRemove,
                    replacementRange: replaceRange,
                    replacementText: "",
                    newSelectedRange: self.textRange(from: start, to: start),
                    currentSelectedRange: self.selectedTextRange
                )
                
                applyUndoableSnapShot(input: result)
                
                return false
            }
        }
        return true
    }
    
    @inlinable
    func getIndentLevel(before text: String) -> Int {
        return text.reduce(0) { count, char in
            switch char {
            case "{", "(", "[": return count + 1
            case "}", ")", "]": return max(0, count - 1)
            default: return count
            }
        }
    }
    
    private func changeInsertion(range: NSRange, indentLevel: Int, insertion: inout String) -> Int {
        var cursorPosition: Int = range.location
        
        let nextCharIndex = self.text.index(self.text.startIndex, offsetBy: range.location, limitedBy: self.text.endIndex)
        
        if let nextCharIndex,
           nextCharIndex < self.text.endIndex,
           range.location - 1 >= 0
        {
            let nextChar = self.text[nextCharIndex]
            let prevCharIndex = self.text.index(self.text.startIndex, offsetBy: range.location - 1)
            let prevChar = self.text[prevCharIndex]

            if MatchingCharacter.isBracketPair(prev: prevChar, next: nextChar) {
                let closingTabs = String(repeating: "\t", count: max(0, indentLevel - 1))
                insertion += "\n" + closingTabs
                cursorPosition = range.location + 1 + indentLevel
            } else {
                cursorPosition = range.location + insertion.count
            }
        }
        return cursorPosition
    }

    func enterCommandExecute(range: NSRange, text: String) -> Bool {
        let fullText = self.text as NSString
        let nsRange = NSMakeRange(0, range.location)
        let beforeText = fullText.substring(with: nsRange)
        
        let indentLevel = getIndentLevel(before: beforeText)
        
        if indentLevel == 0 {
            return true
        }
        
        var insertion = "\n" + String(repeating: "\t", count: indentLevel)
        
        let cursorPosition = changeInsertion(
            range: range,
            indentLevel: indentLevel,
            insertion: &insertion
        )
        
        var replacementRange: UITextRange?
        var replacementText: String = ""
        var newSelectedRange: UITextRange?
        
        // insertion 으로 새로운 문자열 교체
        if let start = self.position(from: self.beginningOfDocument, offset: range.location),
           let end = self.position(from: start, offset: range.length),
           let replaceRange = self.textRange(from: start, to: end) {
            replacementRange = replaceRange
            replacementText = insertion
        }
        
        if let position = self.position(from: self.beginningOfDocument, offset: cursorPosition) {
            newSelectedRange = self.textRange(from: position, to: position)
        }
        
        let result = TextInputCommandResult(
            actionCommandType: .enterCommand,
            replacementRange: replacementRange ?? .init(),
            replacementText: replacementText,
            newSelectedRange: newSelectedRange,
            currentSelectedRange: self.selectedTextRange,
            offset: cursorPosition
        )
        
        applyUndoableSnapShot(input: result)

        return false
    }
}
