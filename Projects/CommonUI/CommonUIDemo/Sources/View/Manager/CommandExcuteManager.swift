import UIKit

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
    
    func commandExecute(shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var systemUpdate = true
        var suggestionEnterCommandExcuted = false
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

        if let start = editor.position(from: editor.beginningOfDocument, offset: range.location),
           let end = editor.position(from: start, offset: range.length),
           let replaceRange = editor.textRange(from: start, to: end) {
            editor.replace(replaceRange, withText: insertion)
        }

        let cursorPosition = range.location + 1
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: cursorPosition) {
            editor.selectedTextRange = editor.textRange(from: position, to: position)
        }
        
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
                editor.replace(replaceRange, withText: "")
                editor.selectedTextRange = editor.textRange(from: start, to: start)
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
        
        // insertion 으로 새로운 문자열 교체
        if let start = editor.position(from: editor.beginningOfDocument, offset: range.location),
           let end = editor.position(from: start, offset: range.length),
           let replaceRange = editor.textRange(from: start, to: end) {
            editor.replace(replaceRange, withText: insertion)
        }
        
        if let position = editor.position(from: editor.beginningOfDocument, offset: cursorPosition) {
            editor.selectedTextRange = editor.textRange(from: position, to: position)
        }

        return false
    }
}
