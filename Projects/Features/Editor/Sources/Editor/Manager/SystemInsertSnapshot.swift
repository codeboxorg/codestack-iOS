import UIKit

final class SystemInsertSnapShot {
    static let shared = SystemInsertSnapShot()
    
    var useWhenTextDidChange: (oldTextRange: UITextRange, shouldChangeTextIn: NSRange, text: String)? = nil
    
    private init() {}
}
