@testable import CommonUIDemo
import UIKit


class MockEditorDelegate: NSObject, UITextViewDelegate {
    var manager: TextInputCommandExcuteManager!
    
    func textViewDidChange(_ textView: UITextView) {
        if let (oldTextRange, nsRange, text) = manager.systemInsertUpdate {
            manager.systemInsertActionSnapShot(
                oldTextRange: oldTextRange,
                shouldChangeTextIn: nsRange,
                replacementText: text
            )
        }
    }
}
