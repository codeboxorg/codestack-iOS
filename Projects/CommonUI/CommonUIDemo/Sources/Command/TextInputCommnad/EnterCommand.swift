import UIKit
import Global

struct EnterCommand: TextInputCommand {
    
    weak var editor: UITextView?
    
    init(_ editor: UITextView?) {
        self.editor = editor
    }
    
    @inlinable
    func shouldHandle(text: String) -> Bool {
        text == "\n" ? true : false
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
    
    func changeInsertion(range: NSRange, indentLevel: Int, insertion: inout String) -> Int {
        guard let editor else {
            return (0)
        }
        var cursorPosition: Int = range.location
        
        let nextCharIndex = editor.text.index(editor.text.startIndex, offsetBy: range.location, limitedBy: editor.text.endIndex)
        
        if let nextCharIndex = nextCharIndex, nextCharIndex < editor.text.endIndex {
            let nextChar = editor.text[nextCharIndex]
            let prevCharIndex = editor.text.index(editor.text.startIndex, offsetBy: range.location - 1)
            let prevChar = editor.text[prevCharIndex]

            let isBracketPair: Bool = {
                switch (prevChar, nextChar) {
                case ("{", "}"), ("[", "]"), ("(", ")"): return true
                default: return false
                }
            }()

            if isBracketPair {
                let closingTabs = String(repeating: "\t", count: max(0, indentLevel - 1))
                insertion += "\n" + closingTabs
                cursorPosition = range.location + 1 + indentLevel
            } else {
                cursorPosition = range.location + insertion.count
            }
        }
        return cursorPosition
    }

    func execute(range: NSRange, text: String) -> Bool {
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
