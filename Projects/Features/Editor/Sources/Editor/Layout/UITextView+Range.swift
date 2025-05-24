import UIKit


extension UITextView {
    func textRange(from beginning: UITextPosition, offset: Int, length: Int) -> UITextRange? {
        guard
            let start = self.position(from: beginning, offset: offset),
            let end = self.position(from: start, offset: length) else {
            return nil
        }
        
        return self.textRange(from: start, to: end)
    }
    
    func textRange(from nsRange: NSRange) -> UITextRange? {
        guard
            let start = self.position(from: self.beginningOfDocument, offset: nsRange.location),
            let end = self.position(from: start, offset: nsRange.length)
        else {
            return nil
        }
        return self.textRange(from: start, to: end)
    }
    
    func nsRange(from textRange: UITextRange) -> NSRange? {
        let location = offset(from: beginningOfDocument, to: textRange.start)
        let length = offset(from: textRange.start, to: textRange.end)
        return NSRange(location: location, length: length)
    }
}
