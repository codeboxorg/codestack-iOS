import UIKit
import Global

final class TextInputCommandExcuteManager {
    weak var editor: UITextView?
    weak var undoableManager: UndoableManager?
    weak var suggestionManager: SuggestionManager?
    weak var suggestionLayoutManger: SuggestionLayout?
    
    private lazy var inputCommands: [TextInputCommand] = [
        SuggestionEnterCommand(
            suggestionManager: self.suggestionManager
        ),
        SuggestionGeneratorCommand(
            suggestionManager: self.suggestionManager
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
        self.undoableManager = undoableManager
        self.suggestionManager = suggestionManager
        self.suggestionLayoutManger = suggestionLayoutManger
    }
    
    func applyUndoableSnapShot(input result: TextInputCommandResult) {
        guard let editor else {
            return
        }
        
        // 1. Get Current TextView Range State
        let oldSelectedTextRange = editor.selectedTextRange
        let replacedText = editor.text(in: result.replacementRange) ?? ""
        var newSelectedTextRange: UITextRange? = nil
        
        // 2. Recalculate new selectedTextRange after replacement
        if let newSelectedRange = result.newSelectedRange,
           let _newSelectedTextRange = editor.textRange(
            from: editor.beginningOfDocument,
            offset: editor.offset(from: editor.beginningOfDocument, to: newSelectedRange.start),
            length: 0
           )
        {
            newSelectedTextRange = _newSelectedTextRange
        }

        // 3. Recalculate undo range based on the updated state
        let startOffset = editor.offset(from: editor.beginningOfDocument, to: result.replacementRange.start)
        let undoRange = editor.textRange(from: editor.beginningOfDocument, offset: startOffset, length: result.replacementText.count)

        editor.replace(result.replacementRange, withText: result.replacementText)
        editor.selectedTextRange = newSelectedTextRange

        // 4. Create undo command with updated selectedTextRange
        let undoCommand = UndoSnapshotCommand(
            undoRange: undoRange,
            redoRange: result.replacementRange,
            insertedText: result.replacementText,
            replacedText: replacedText,
            selectedTextRange: newSelectedTextRange,
            oldSelectedTextRange: oldSelectedTextRange
        )

        // 5. Push undo command and cancel further processing
    func systemRemoveActionSnapShot(shouldChangeTextIn range: NSRange, replacementText text: String) {
        guard let editor else {
            return
        }
        let priorWord = (editor.text as NSString).substring(with: range)
        let oldSelectedRange = editor.selectedTextRange
        let startPosition = editor.position(from: editor.beginningOfDocument, offset: range.location)
        let undoEndPosition = editor.position(from: startPosition ?? UITextPosition(), offset: range.length - priorWord.count)
        let redoEndPosition = editor.position(from: startPosition ?? UITextPosition(), offset: range.length)

        var undoRange: UITextRange? = nil
        var redoRange: UITextRange? = nil

        if let start = startPosition, let end = undoEndPosition, let redo_end = redoEndPosition {
            undoRange = editor.textRange(from: start, to: end)
            redoRange = editor.textRange(from: start, to: redo_end)
        }

        let cursorOffset = range.location
        let newCursorPosition = editor.position(from: editor.beginningOfDocument, offset: cursorOffset)
        let selectedTextRange = newCursorPosition.flatMap { editor.textRange(from: $0, to: $0) }

        let undoCommand = UndoSnapshotCommand(
            undoRange: undoRange,
            redoRange: redoRange,
            insertedText: text,
            replacedText: priorWord,
            selectedTextRange: selectedTextRange,
            oldSelectedTextRange: oldSelectedRange
        )

        undoableManager?.push(undoCommand)
    }
    
    func systemInsertActionSnapShot(shouldChangeTextIn range: NSRange, replacementText text: String) {
        guard let editor else {
            return
        }
        let priorWord = (editor.text as NSString).substring(with: range)
        let oldSelectedRange = editor.selectedTextRange

        let undoStartPosition = editor.position(from: editor.beginningOfDocument, offset: range.location)
        let undoEndPosition = editor.position(from: undoStartPosition ?? UITextPosition(), offset: range.length + text.count)
        let redoEndPosition = editor.position(from: undoStartPosition ?? UITextPosition(), offset: range.length)

        var undoRange: UITextRange? = nil
        var redoRange: UITextRange? = nil
        if let start = undoStartPosition, let end = undoEndPosition, let redo_end = redoEndPosition {
            undoRange = editor.textRange(from: start, to: end)
            redoRange = editor.textRange(from: start, to: redo_end)
        }
        
        let cursorOffset = range.location + text.count
        let newCursorPosition = editor.position(from: editor.beginningOfDocument, offset: cursorOffset)
        let selectedTextRange = newCursorPosition.flatMap { editor.textRange(from: $0, to: $0) }

        let undoCommand = UndoSnapshotCommand(
            undoRange: undoRange,
            redoRange: redoRange,
            insertedText: text,
            replacedText: priorWord,
            selectedTextRange: selectedTextRange,
            oldSelectedTextRange: oldSelectedRange
        )

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
                systemRemoveActionSnapShot(shouldChangeTextIn: range, replacementText: text)
            } else {
                systemInsertActionSnapShot(shouldChangeTextIn: range, replacementText: text)
            }
        }
        
        return systemUpdate
    }
}

// MARK: Auto Pair Command
extension TextInputCommandExcuteManager {
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
            editor.selectedTextRange = newSelectedRange
        }
        
        let result = TextInputCommandResult(
            replacementRange: replacementRange ?? .init(),
            replacementText: replacementText,
            newSelectedRange: newSelectedRange
        )
        
        applyUndoableSnapShot(input: result)
        
        return false
    }
}

// MARK: Auto Remove Command
extension TextInputCommandExcuteManager {
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
                    replacementRange: replaceRange,
                    replacementText: "",
                    newSelectedRange: editor.textRange(from: start, to: start)
                )
                
                applyUndoableSnapShot(input: result)
                
                return false
            }
        }
        return true
    }
}

// MARK: Enter Command
extension TextInputCommandExcuteManager {
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
    
    func changeInsertion(range: NSRange, indentLevel: Int, insertion: inout String) -> Int {
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
            // editor.selectedTextRange = editor.textRange(from: position, to: position)
            newSelectedRange = editor.textRange(from: position, to: position)
        }
        
        let result = TextInputCommandResult(
            replacementRange: replacementRange ?? .init(),
            replacementText: replacementText,
            newSelectedRange: newSelectedRange
        )
        
        applyUndoableSnapShot(input: result)

        return false
    }
}
