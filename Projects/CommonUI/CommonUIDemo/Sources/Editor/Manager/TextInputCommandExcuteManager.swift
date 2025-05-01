import UIKit
#if DEV
import Global
#endif


protocol TextInputCommandExcuteManager {
    func commandExecute(shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func systemInsertActionSnapShot(oldTextRange: UITextRange, shouldChangeTextIn range: NSRange, replacementText text: String)
}

protocol EnterCommandExecutor: AnyObject {
    func enterCommandExecute(range: NSRange, text: String) -> Bool
}

protocol AutoRemoveCommandExecutor: AnyObject {
    func autoRemoveCommandExecute(range: NSRange, text: String) -> Bool
}

protocol AutoPairCommandExecutor: AnyObject {
    func autoPairExecute(range: NSRange, text: String) -> Bool
}

final class DefaultTextInputCommandExcuteManager: TextInputCommandExcuteManager,
                                                  EnterCommandExecutor,
                                                  AutoRemoveCommandExecutor,
                                                  AutoPairCommandExecutor {
    weak var editor: UITextView?
    weak var undoableManager: UndoableManager?
    weak var suggestionManager: SuggestionManager?
    weak var suggestionLayoutManger: SuggestionLayout?
    
    var resolver: TextRangeResolver
    
    private lazy var inputCommands: [TextInputCommand] = [
        SuggestionEnterCommand(
            suggestionManager: self.suggestionManager as? SuggestionInsert
        ),
        SuggestionGeneratorCommand(
            suggestionManager: self.suggestionManager as? SuggestionGenerator
        ),
        EnterCommand(
            suggestionLayout: self.suggestionLayoutManger,
            commandExecutor: self
        ),
        AutoRemoveCommand(commandExecutor: self),
        AutoPairCharacterCommand(commandExecutor: self),
    ]
    
    init(
        editor: UITextView?,
        undoableManager: UndoableManager?,
        suggestionManager: SuggestionManager?,
        suggestionLayoutManger: SuggestionLayout?
    )
    {
        self.editor = editor
        resolver = TextRangeResolver(editor: editor!)
        self.undoableManager = undoableManager
        self.suggestionManager = suggestionManager
        self.suggestionLayoutManger = suggestionLayoutManger
    }
    
    func systemInsertActionSnapShot(oldTextRange: UITextRange, shouldChangeTextIn range: NSRange, replacementText text: String) {
        let undoCommand = resolver.insertSnapshot(oldTextRange, range, text)
        
        undoableManager?.push(undoCommand)
    }
    
    func commandExecute(shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var systemUpdate = true
        var state = Set<CommandExcuteState>()
        
        for command in inputCommands {
            if command.shouldHandle(text: text, state: state) {
                let commandUpdate = command.execute(
                    range: range,
                    text: text,
                    state: &state
                )
                if commandUpdate == false {
                    systemUpdate = false
                }
            }
        }
        
        if systemUpdate {
            if range.length >= 1 && text.count == 0 {
                let undoCommand = resolver.removeSnapShot(range, text)
                undoableManager?.push(undoCommand)
            } else if range.length >= 1 && text.count != 0 {
                let undoCommand = resolver.replaceSnapshot(range, text)
                undoableManager?.push(undoCommand)
            } else {
                SystemInsertSnapShot.shared.useWhenTextDidChange = (editor!.selectedTextRange!, range, text)
            }
            return true
        } else {
            return false
        }
    }
}

extension DefaultTextInputCommandExcuteManager {
    private func applyUndoableSnapShot(input result: TextInputCommandResult) {
        guard let editor else {
            return
        }
        
        editor.replace(result.replacementRange, withText: result.replacementText)
        
        let snapShot = resolver.applyUndoableSnapShot(result)
        
        editor.selectedTextRange = snapShot.getNewSelectedRange
        
        undoableManager?.push(snapShot)
    }
}

// MARK: Auto Pair Command
extension DefaultTextInputCommandExcuteManager {
    func autoPairExecute(range: NSRange, text: String) -> Bool {
        guard let editor = editor else {
            return true
        }
        
        guard let value = MatchingCharacter.matchingCharacter(text), value.isOpening else {
            return true
        }
        
        let insertion = "\(value.rawValue)\(value.pair)"
        
        var replacementRange: UITextRange?
        var replacementText : String = ""
        var newSelectedRange: UITextRange?
        
        if let start = editor.position(from: editor.beginningOfDocument, offset: range.location),
           let end = editor.position(from: start, offset: range.length),
           let replaceRange = editor.textRange(from: start, to: end) {
            replacementRange = replaceRange
            replacementText = insertion
        }

        let cursorPosition = range.location + 1
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: cursorPosition) {
            newSelectedRange = editor.textRange(from: position, to: position)
        }
        
        let result = TextInputCommandResult(
            actionCommandType: .autoPairInsert,
            replacementRange: replacementRange ?? .init(),
            replacementText: replacementText,
            newSelectedRange: newSelectedRange,
            currentSelectedRange: editor.selectedTextRange,
            offset: newSelectedRange == nil ? cursorPosition : nil
        )
        
        applyUndoableSnapShot(input: result)
        
        return false
    }
}

// MARK: Auto Remove Command
extension DefaultTextInputCommandExcuteManager {
    func autoRemoveCommandExecute(range: NSRange, text: String) -> Bool {
        guard let editor else {
            return true
        }
        
        let removalIndex = editor.text.index(editor.text.startIndex, offsetBy: range.location, limitedBy: editor.text.endIndex)
        let prevCharIndex = editor.text.index(editor.text.startIndex, offsetBy: range.location + 1, limitedBy: editor.text.endIndex)
        let end = editor.text.endIndex
        
        if let removalIndex,
           let prevCharIndex,
           removalIndex < end,
           prevCharIndex < end
        {
            let willRemoveChar = editor.text[removalIndex]
            let prevChar = editor.text[prevCharIndex]
            
            if MatchingCharacter.removalPair(prev: willRemoveChar, next: prevChar),
               let start = editor.position(from: editor.beginningOfDocument, offset: range.location),
               let end   = editor.position(from: start, offset: 2),
               let replaceRange = editor.textRange(from: start, to: end)
            {
                let result = TextInputCommandResult(
                    actionCommandType: .autoPairRemove,
                    replacementRange: replaceRange,
                    replacementText: "",
                    newSelectedRange: editor.textRange(from: start, to: start),
                    currentSelectedRange: editor.selectedTextRange
                )
                
                applyUndoableSnapShot(input: result)
                
                return false
            }
        }
        return true
    }
}

// MARK: Enter Command
extension DefaultTextInputCommandExcuteManager {
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
        guard let editor else {
            return (0)
        }
        var cursorPosition: Int = range.location
        
        let nextCharIndex = editor.text.index(editor.text.startIndex, offsetBy: range.location, limitedBy: editor.text.endIndex)
        
        if let nextCharIndex,
           nextCharIndex < editor.text.endIndex,
           range.location - 1 >= 0
        {
            let nextChar = editor.text[nextCharIndex]
            let prevCharIndex = editor.text.index(editor.text.startIndex, offsetBy: range.location - 1)
            let prevChar = editor.text[prevCharIndex]

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
        guard let editor = editor else {
            return true
        }

        let fullText = editor.text as NSString
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
        if let start = editor.position(from: editor.beginningOfDocument, offset: range.location),
           let end = editor.position(from: start, offset: range.length),
           let replaceRange = editor.textRange(from: start, to: end) {
            replacementRange = replaceRange
            replacementText = insertion
        }
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: cursorPosition) {
            newSelectedRange = editor.textRange(from: position, to: position)
        }
        
        let result = TextInputCommandResult(
            actionCommandType: .enterCommand,
            replacementRange: replacementRange ?? .init(),
            replacementText: replacementText,
            newSelectedRange: newSelectedRange,
            currentSelectedRange: editor.selectedTextRange,
            offset: cursorPosition
        )
        
        applyUndoableSnapShot(input: result)

        return false
    }
}
