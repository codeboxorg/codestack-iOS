
import UIKit

struct TextRangeCalculator {
    weak var editor: UITextView!
    
    init(editor: UITextView) {
        self.editor = editor
    }
    
    func textRange(from beginning: UITextPosition, offset: Int, length: Int) -> UITextRange? {
        guard let start = editor.position(from: beginning, offset: offset)
                ,let end = editor.position(from: start, offset: length) else {
            return nil
        }
        
        return editor.textRange(from: start, to: end)
    }
    
    func textRange(from nsRange: NSRange) -> UITextRange? {
        guard
            let start = editor.position(from: editor.beginningOfDocument, offset: nsRange.location),
            let end = editor.position(from: start, offset: nsRange.length)
        else {
            return nil
        }
        return editor.textRange(from: start, to: end)
    }
}
