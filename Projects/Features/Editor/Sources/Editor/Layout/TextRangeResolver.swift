import UIKit

struct TextRangeResolver {
    weak var editor: UITextView!
    
    init(editor: UITextView) {
        self.editor = editor
    }
    
    func applyUndoableSnapShot(_ result: TextInputCommandResult) -> UndoSnapshotCommand {
        // 1. Get Current TextView Range State
        let oldSelectedTextRange = result.currentSelectedRange
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
        } else if result.newSelectedRange == nil, let offset = result.offset,
           let position = editor.position(from: editor.beginningOfDocument, offset: offset)
        {
            newSelectedTextRange = editor.textRange(from: position, to: position)
        }

        // 3. Recalculate undo range based on the updated state
        let startOffset = editor.offset(from: editor.beginningOfDocument, to: result.replacementRange.start)
        let undoRange = editor.textRange(from: editor.beginningOfDocument, offset: startOffset, length: result.replacementText.utf16.count)
        
        return UndoSnapshotCommand(
            actionCommandType: result.actionCommandType,
            undoRange: undoRange,
            redoRange: result.replacementRange,
            insertedText: result.replacementText,
            replacedText: replacedText,
            selectedTextRange: newSelectedTextRange,
            oldSelectedTextRange: oldSelectedTextRange
        )
    }
    
    func replaceSnapshot(_ range: NSRange, _ text: String) -> UndoSnapshotCommand {
        let priorWord = (editor.text as NSString).substring(with: range)
        
        let startPosition = editor.position(from: editor.beginningOfDocument, offset: range.location)
        let undoEndPosition = editor.position(from: startPosition ?? UITextPosition(), offset: range.length - priorWord.utf16.count + text.utf16.count)
        let redoEndPosition = editor.position(from: startPosition ?? UITextPosition(), offset: range.length)
        
        var undoRange: UITextRange? = nil
        var redoRange: UITextRange? = nil

        if let start = startPosition, let end = undoEndPosition, let redo_end = redoEndPosition {
            undoRange = editor.textRange(from: start, to: end)
            redoRange = editor.textRange(from: start, to: redo_end)
        }
        
        let cursorOffset = range.location + text.utf16.count
        let newCursorPosition = editor.position(from: editor.beginningOfDocument, offset: cursorOffset)
        let selectedTextRange = newCursorPosition.flatMap { editor.textRange(from: $0, to: $0) }
        
        return UndoSnapshotCommand(
            actionCommandType: .systemReplace,
            undoRange: undoRange,
            redoRange: redoRange,
            insertedText: text,
            replacedText: priorWord,
            selectedTextRange: selectedTextRange,
            oldSelectedTextRange: editor.selectedTextRange
        )
    }
    
    func removeSnapShot(_ range: NSRange, _ text: String) -> UndoSnapshotCommand {
        let priorWord = (editor.text as NSString).substring(with: range)
        let oldSelectedRange = editor.selectedTextRange
        let startPosition = editor.position(from: editor.beginningOfDocument, offset: range.location)
        let undoEndPosition = editor.position(from: startPosition ?? UITextPosition(), offset: range.length - priorWord.utf16.count)
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
        
        return UndoSnapshotCommand(
            actionCommandType: .systemRemove,
            undoRange: undoRange,
            redoRange: redoRange,
            insertedText: text,
            replacedText: priorWord,
            selectedTextRange: selectedTextRange,
            oldSelectedTextRange: oldSelectedRange
        )
    }
    
    func insertSnapshot(_ oldTextRange: UITextRange, _ range: NSRange, _ text: String) -> UndoSnapshotCommand {
        let priorWord = (editor.text as NSString).substring(with: range)
        let oldSelectedRange = oldTextRange

        let undoStartPosition = editor.position(from: editor.beginningOfDocument, offset: range.location)
        let undoEndPosition = editor.position(from: undoStartPosition ?? UITextPosition(), offset: range.length + text.utf16.count)
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

        return UndoSnapshotCommand(
            actionCommandType: .systemInput,
            undoRange: undoRange,
            redoRange: redoRange,
            insertedText: text,
            replacedText: priorWord,
            selectedTextRange: selectedTextRange,
            oldSelectedTextRange: oldSelectedRange
        )
    }
    
    func deleteLineSnapShot() -> UndoSnapshotCommand? {
        // 1. Define paragraph range and contents
        let paragraphRange = (editor.text as NSString).paragraphRange(for: editor.selectedRange)
        let paragraphText = (editor.text as NSString).substring(with: paragraphRange)
        let oldSelectedTextRange = editor.selectedTextRange
        
        // 2. Calculate undo and redo text ranges
        guard let startPosition = editor.position(from: editor.beginningOfDocument, offset: paragraphRange.location),
              let redoEndPosition = editor.position(from: startPosition, offset: paragraphRange.length) else {
            return nil 
        }
        
        let undoEndPosition = startPosition // Undo deletes everything → undo range is empty at start
        let undoRange = editor.textRange(from: startPosition, to: undoEndPosition)
        let redoRange = editor.textRange(from: startPosition, to: redoEndPosition)
        
        // 3. Determine new cursor position after deletion
        let newCursorOffset = max(0, paragraphRange.location - 1)
        let newCursorPosition = editor.position(from: editor.beginningOfDocument, offset: newCursorOffset)
        let newSelectedTextRange = newCursorPosition.flatMap { editor.textRange(from: $0, to: $0) }
        
        // 4. Register Undo Snapshot
        return UndoSnapshotCommand(
            actionCommandType: .systemRemove,
            undoRange: undoRange,
            redoRange: redoRange,
            insertedText: "",
            replacedText: paragraphText,
            selectedTextRange: newSelectedTextRange,
            oldSelectedTextRange: oldSelectedTextRange
        )
    }
}
